<?php
include 'db.php';
include 'validate.php';
	try {
		if (!isset($_POST['deviceid'])) { exit(); }
		$uid = base64_decode($_POST['deviceid']);
		if (!validateDeviceID($db,$uid)) { exit(); }
		$token_length = 16;
		$token = bin2hex(random_bytes($token_length));
		//Add after validation function
		//$uid = password_hash(base64_encode(hash('sha256', $_POST['deviceid'], true)),PASSWORD_DEFAULT);
		$stmt = $db->prepare('DELETE FROM login_token WHERE uid=? or (expire - NOW()) < 1');
		$stmt->bindValue(1, $uid, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare('INSERT INTO login_token (uid,token,expire) VALUES (?,?,NOW()+INTERVAL 600 SECOND)');
		$stmt->bindValue(1, $uid, PDO::PARAM_INT);
		$stmt->bindValue(2, $token, PDO::PARAM_STR);
		$stmt->execute();
		$resp = "{\n\"login_token\": \"".$token."\"\n}";

		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured! $ex";
	}
?>