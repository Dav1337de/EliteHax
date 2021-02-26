<?php
include 'db.php';
include 'validate.php';
	try {
		if ((!isset($_POST['deviceid'])) or (!isset($_POST['data']))) { exit(); }
		//Base64Decode
		$data = base64_decode($_POST['data']);
		$uid = base64_decode($_POST['deviceid']);
		//Get Token from UID
		if (!validateDeviceID($db,$uid)) { exit(); }
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
		$email = $json["email"];
		if (!validateUser($user)) { exit(); }
		if (!validateEmail($email)) { exit(); }
		//Check pending user and e-mails
		$stmt = $db->prepare('SELECT username,email FROM register_pending WHERE username=? and email=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->bindValue(2, $email, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			exit(base64_encode("{\"status\": \"PA\"}"));
		}
		//Check Reset Attempts
		$stmt = $db->prepare('SELECT id,valid,(NOW()-timestamp) as diff FROM reset_attempt WHERE (username=? or ip_address=?) and (NOW()-timestamp) <= 3600 order by timestamp DESC');
		$stmt->bindValue(1, $user, PDO::PARAM_STR);
		$stmt->bindValue(2, $_SERVER['REMOTE_ADDR'], PDO::PARAM_STR);
		$stmt->execute();		
		$reset_attempts = $stmt->rowCount();

		if ($reset_attempts > 0) {
			$row = $stmt->fetch(PDO::FETCH_ASSOC);		
			$last_reset = $row['diff'];
			$last_reset_status = $row['valid']; 
			if ($last_reset_status == 1) { exit(base64_encode("{\n\"status\": \"WAIT\"\n}")); }
			elseif ($last_reset <= 600) {
				exit(base64_encode("{\n\"status\": \"TME\"\n}"));
			}				
		}
		
		//Check active user and e-mails
		$stmt = $db->prepare('SELECT username,email FROM user WHERE username=? and email=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->bindValue(2, $email, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			$stmt = $db->prepare('INSERT INTO reset_attempt (username, email, ip_address, timestamp, valid) VALUES (?,?,?,NOW(),0)');
			$stmt->bindValue(1, $user, PDO::PARAM_INT);
			$stmt->bindValue(2, $email, PDO::PARAM_STR);
			$stmt->bindValue(3, $_SERVER['REMOTE_ADDR'], PDO::PARAM_STR);
			$stmt->execute();
			exit(base64_encode("{\"status\": \"NA\"}"));
		}
		else {
			//Activation Token
			$token_length = 16;
			$hmac_length = 128;
			$token = bin2hex(random_bytes($token_length));
			$hmac_key = bin2hex(random_bytes($hmac_length));
			
			$stmt = $db->prepare('INSERT INTO password_reset (username, email, reset_token, token_expire, hmac, uid, ip_address, timestamp) VALUES (?,?,?,NOW()+INTERVAL 3 DAY,?,?,?,NOW())');
			$stmt->bindValue(1, $user, PDO::PARAM_INT);
			$stmt->bindValue(2, $email, PDO::PARAM_STR);
			$stmt->bindValue(3, $token, PDO::PARAM_STR);
			$stmt->bindValue(4, $hmac_key, PDO::PARAM_STR);
			$stmt->bindValue(5, $uid, PDO::PARAM_STR);
			$stmt->bindValue(6, $_SERVER['REMOTE_ADDR'], PDO::PARAM_STR);
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
			$reset_url = base64_encode(hash_hmac('sha256', $message, $hmac_key, true) . $message);
			//Send E-mail
			$to      = $email;
			$subject = 'EliteHax Password Reset';
			$message = "Dear ".$user.",\nPlease click here to set a new password for EliteHax game:\nhttps://app.elitehax.it/setNewPassword.php?code=".urlencode($reset_url)."\n\nIf you didn't request to reset your EliteHax password ignore this e-mail.\n\nEliteHax Team";
			$headers = 'From: EliteHax';
			mail($to, $subject, $message, $headers);
			//INSERT IN RESET_ATTEMPT
			$stmt = $db->prepare('INSERT INTO reset_attempt (username, email, ip_address, timestamp, valid) VALUES (?,?,?,NOW(),1)');
			$stmt->bindValue(1, $user, PDO::PARAM_INT);
			$stmt->bindValue(2, $email, PDO::PARAM_STR);
			$stmt->bindValue(3, $_SERVER['REMOTE_ADDR'], PDO::PARAM_STR);
			$stmt->execute();
			$resp = "{\n\"status\": \"OK\",\n\"code\": \"".$reset_url."\"\n}";
		}

		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured! $ex";
	}
?>