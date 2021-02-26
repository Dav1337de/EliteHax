<?php
function validateUser($username) {
	if ((strlen($username) < 4) or (strlen($username) > 18)) { 
		return false;
	}
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\ ]/",$username)) {
		return false;
	}
	return true;
}

function validateDeviceID($deviceid) {
	if ((strlen($deviceid) < 10) or (strlen($deviceid) > 32)) { 
		return false;
	}
	if (preg_match("/[^a-zA-Z0-9]/",$deviceid)) {
		return false;
	}
	return true;
}

function validateEmail($email) {
	if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
		return true;
	} else {
		return false;
	}
}

function getIdFromToken($db) {
	if (!isset($_POST['id'])) { exit(); }
	else {
		$input = $_POST['id'];
		//Base64 Decode
		$decoded = base64_decode($input);
		if ($decoded === false) { exit("Not base64"); }
		//HMAC Retrieve
		$mac = mb_substr($decoded, 0, 32, '8bit'); // stored
		$message = mb_substr($decoded, 32, null, '8bit');
		//JSON Decode and Check
		$json = json_decode($message,true);
		$token = base64_decode($json["token"]);
		$id = base64_decode($json["id"]);
		$expires = $json["expires"];
		if (($token == null) or ($id == null) or ($expires==null)) { exit("Missing parameters"); }
		//E-mail and Token Check
		$stmt = $db->prepare('SELECT * FROM player_token WHERE id=? and token=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $token, PDO::PARAM_STR);
		$stmt->execute();	
		if ($stmt->rowCount() == 0) { exit("Token not found"); }
		else {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$id = $row["id"];
				$hmac_key = $row["hmac"];
			}
		}
		//HMAC Check
		$calc = hash_hmac('sha256', $message, $hmac_key, true); // calcuated
		if (!hash_equals($calc, $mac)) {
			exit("HMAC not match");
		}
		//Expire Check
		$currTime = new DateTime('NOW');
		$expireTime = new DateTime($json["expires"]);
		if ($currTime > $expireTime) {
			exit("Token Expired");
		}
		return $id;
	}
}
?>