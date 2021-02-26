<?php
include 'db.php';
include 'validate.php';
	try {
		if ((!isset($_POST['deviceid'])) or (!isset($_POST['data']))) { exit(); }
		//Base64Decode
		$data = base64_decode($_POST['data']);
		$uid = base64_decode($_POST['deviceid']);
		//Get Token from UID
		if (!validateDeviceID($uid)) { exit(); }
		$stmt = $db->prepare('DELETE FROM register_token WHERE (expire - NOW()) < 1');
		$stmt->execute();
		$stmt = $db->prepare('SELECT token FROM register_token WHERE uid=?');
		$stmt->bindValue(1, $uid, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { exit(); }
		else {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$user_token = $row['token'];
			}
		}
		//AES256 Decrypt
		$method = 'aes-256-cbc';
		$decrypted = openssl_decrypt ($_POST['data'], $method, $user_token);
		//JSON Decode
		$json = json_decode($decrypted, true);
		$user = $json["user"];
		$password = $json["password"];
		$email = $json["email"];
		if (!validateUser($user)) { exit(); }
		if (!validateEmail($email)) { exit(); }
		//Check active user and e-mails
		$stmt = $db->prepare('SELECT username,email FROM user WHERE username=? or email=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->bindValue(2, $email, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (strcasecmp($user, $row['username']) == 0) { exit(base64_encode("{\"status\": \"UE\"}")); }
				if (strcasecmp($email, $row['email']) == 0) { exit(base64_encode("{\"status\": \"EE\"}")); }
			}
		}
		//Check pending user and e-mails
		$stmt = $db->prepare('SELECT username,email FROM register_pending WHERE username=? or email=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->bindValue(2, $email, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (strcasecmp($user, $row['username']) == 0) { exit(base64_encode("{\"status\": \"UE\"}")); }
				if (strcasecmp($email, $row['email']) == 0) { exit(base64_encode("{\"status\": \"EE\"}")); }
			}
		}
		else {
			//Activation Token
			$token_length = 16;
			$hmac_length = 128;
			$token = bin2hex(random_bytes($token_length));
			$hmac_key = bin2hex(random_bytes($hmac_length));
			$password = password_hash(base64_encode(hash('sha256', $password, true)),PASSWORD_DEFAULT);
			
			$stmt = $db->prepare('INSERT INTO register_pending (username, password, email, activation_token, token_expire, hmac, uid) VALUES (?,?,?,?,NOW()+INTERVAL 3 DAY,?,?)');
			$stmt->bindValue(1, $user, PDO::PARAM_INT);
			$stmt->bindValue(2, $password, PDO::PARAM_STR);
			$stmt->bindValue(3, $email, PDO::PARAM_STR);
			$stmt->bindValue(4, $token, PDO::PARAM_STR);
			$stmt->bindValue(5, $hmac_key, PDO::PARAM_STR);
			$stmt->bindValue(6, $uid, PDO::PARAM_STR);
			$stmt->execute();
			$expires = new DateTime('now');
			$expires->add(new DateInterval('P3D'));
			$message = json_encode([
				'token' => base64_encode($token),
				'email' => base64_encode($email),
				'expires' => $expires->format('Y-m-d\TH:i:s')
			]);
			//Delete Registration Token
			$stmt = $db->prepare('DELETE FROM register_token WHERE uid=?');
			$stmt->bindValue(1, $uid, PDO::PARAM_INT);
			$stmt->execute();
			//URL
			$activation_url = base64_encode(hash_hmac('sha256', $message, $hmac_key, true) . $message);
			//Send E-mail
			$to      = $email;
			$subject = 'EliteHax Account Activation';
			$message = "Dear ".$user.",\nPlease click here to confirm the registration to EliteHax game:\nhttps://app.elitehax.it/registrationConfirm.php?code=".urlencode($activation_url)."\n\nIf you didn't request access to EliteHax ignore this e-mail.\n\nEliteHax Team";
			$headers = 'From: EliteHax';
			mail($to, $subject, $message, $headers);
			$resp = "{\n\"status\": \"OK\",\n\"code\": \"".$activation_url."\"\n}";
		}

		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured! $ex";
	}
?>