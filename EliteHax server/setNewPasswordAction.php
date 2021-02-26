<?php
include 'db.php';
include 'validate.php';
	try {
		if (!isset($_GET['code'])) { exit("Missing CODE"); }
		$input = $_GET['code'];
		//Base64 Decode
		$decoded = base64_decode($input);
		if ($decoded === false) { exit("INVALID CODE"); }
		//HMAC Retrieve
		$mac = mb_substr($decoded, 0, 32, '8bit'); // stored
		$message = mb_substr($decoded, 32, null, '8bit');
		//JSON Decode and Check
		$json = json_decode($message,true);
		$token = base64_decode($json["token"]);
		$email = base64_decode($json["email"]);
		$expires = $json["expires"];
		if (($token == null) or ($email == null) or ($expires==null)) { exit("INCOMPLETE CODE"); }
		//E-mail and Token Check
		$stmt = $db->prepare('SELECT * FROM password_reset WHERE email=? and reset_token=?');
		$stmt->bindValue(1, $email, PDO::PARAM_STR);
		$stmt->bindValue(2, $token, PDO::PARAM_STR);
		$stmt->execute();	
		if ($stmt->rowCount() == 0) { exit("TOKEN NOT FOUND"); }
		else {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$username = $row["username"];
				$password = $row["password"];
				$email = $row["email"];
				$hmac_key = $row["hmac"];
			}
		}
		//HMAC Check
		$calc = hash_hmac('sha256', $message, $hmac_key, true); // calcuated
		if (!hash_equals($calc, $mac)) {
			exit("INVALID CHECKSUM");
		}
		//Expire Check
		$currTime = new DateTime('NOW');
		$expireTime = new DateTime($json["expires"]);
		if ($currTime > $expireTime) {
			exit("TOKEN EXPIRED");
		}
		if ((!isset($_POST['newPassword'])) or (!isset($_POST['confirmPassword']))) { exit(); }
		$new_pwd=$_POST['newPassword'];
		$confirm_pwd=$_POST['confirmPassword'];
		if (strlen($new_pwd) < 10) { exit("New Password is too short! Use at least 10 Characters."); }
		elseif (strlen($new_pwd) > 30) { exit("New Password is too long! Max length is 30 Characters."); }
		elseif ($new_pwd != $confirm_pwd) { exit("Passwords don't match!."); }
		$password = password_hash(base64_encode(hash('sha256', $new_pwd, true)),PASSWORD_DEFAULT);
		$stmt = $db->prepare('UPDATE user SET password=? WHERE email=?');
		$stmt->bindValue(1, $password, PDO::PARAM_INT);
		$stmt->bindValue(2, $email, PDO::PARAM_STR);
		$stmt->execute();
		
		$stmt = $db->prepare('DELETE FROM password_reset WHERE email=? and reset_token=?');
		$stmt->bindValue(1, $email, PDO::PARAM_STR);
		$stmt->bindValue(2, $token, PDO::PARAM_STR);
		$stmt->execute();
		
		echo "New password has been set!";
		
	} catch(PDOException $ex) {
		echo "An Error occured! $ex";
	}
?>