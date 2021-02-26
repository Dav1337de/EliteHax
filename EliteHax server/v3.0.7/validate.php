<?php
require '../dashboard/nameapi-client-php-master/src/org/nameapi/client/services/ServiceFactory.php';
use org\nameapi\client\services\Host;
use org\nameapi\client\services\ServiceFactory;
use org\nameapi\ontology\input\context\Context;
use org\nameapi\ontology\input\context\Priority;

function verify_market_in_app($signed_data, $signature, $public_key_base64) 
{
	$key =	"-----BEGIN PUBLIC KEY-----\n".
		chunk_split($public_key_base64, 64,"\n").
		'-----END PUBLIC KEY-----';   
	//using PHP to create an RSA key
	$key = openssl_get_publickey($key);
	//$signature should be in binary format, but it comes as BASE64. 
	//So, I'll convert it.
	$signature = base64_decode($signature);   
	//using PHP's native support to verify the signature
	$result = openssl_verify(
			$signed_data,
			$signature,
			$key,
			OPENSSL_ALGO_SHA1);
	if (0 === $result) 
	{
		return false;
	}
	else if (1 !== $result)
	{
		return false;
	}
	else 
	{
		return true;
	}
} 

function validateUser($username) {
	if ((strlen($username) < 4) or (strlen($username) > 18)) { 
		return false;
	}
	$chars = preg_match_all( "/[a-zA-Z0-9]/", $username );
	if ($chars < 4) {
		return false;
	}
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\ ]/",$username)) {
		return false;
	}
	return true;
}

function validateDeviceID($db,$deviceid) {
	if ($deviceid=='9971f4d9bcf5d6e0') {
		return false;
	}
	//Device Ban Check
	$stmt = $db->prepare('SELECT * FROM ban_device WHERE device_id=?');
	$stmt->bindValue(1, $deviceid, PDO::PARAM_STR);
	$stmt->execute();	
	if ($stmt->rowCount() != 0) { 
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$reason = $row["reason"];
		}
		exit(base64_encode("{\n\"BAN\": \"Y\",\n\"reason\": \"".$reason."\"\n}"));
	}
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
		//Ban Specific strings
		//if (strpos($email, 'yopmail') !== false) {
		//	return false;
		//}
		//Check disposable emails
		$context = Context::builder()
					->priority(Priority::REALTIME())
					->build();
		$myApiKey = 'XXX'; //GitHub Note: grab one from nameapi.org
		$serviceFactory = new ServiceFactory($myApiKey, $context, Host::http('rc53-api.nameapi.org'), '5.3');
		//the call:
		$deaDetector = $serviceFactory->emailServices()->disposableEmailAddressDetector();
		$result = $deaDetector->isDisposable($email);
		if (strpos($email, 'test-308b3') !== false) {
			return true;
		}
		if (((string)$result->getDisposable()=='YES') or ((string)$result->getDisposable()=='UNKNOWN')) {
			exit(base64_encode("{\"status\": \"EN\"}"));
		}
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

function checkNonce($db,$id) {
	if (!isset($_POST['data'])) { exit(""); }
	else {
		$data = $_POST['data'];
		//Base64 Decode
		$decoded = base64_decode($data);
		if ($decoded === false) { exit(""); }
		
		//AES256 Decrypt
		$method = 'aes-256-cbc';
		//GitHub Note: Use the same AES256 key used in mydata.lua
		$decrypted1 = openssl_decrypt( $_POST['data'], $method, 'XXX');
		
		//Device ID Decrypt
		$stmt = $db->prepare('SELECT device_id FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$device_id=base64_encode($row['device_id']);
		}	
		$decrypted = openssl_decrypt ($decrypted1, $method, md5($device_id));
		
		//JSON Decode
		$json = json_decode($decrypted, true);
		$nonce = $json['nonce'];
		$timestamp = $json['timestamp'];
		if (($nonce==null) or ($timestamp==null)) { exit(""); }
		$stmt = $db->prepare('SELECT id FROM nonces WHERE user_id=? and nonce=? and timestamp=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $nonce, PDO::PARAM_INT);
		$stmt->bindValue(3, $timestamp, PDO::PARAM_INT);
		$stmt->execute();	
		if ($stmt->rowCount() != 0) { exit(""); }
		else {
			$stmt = $db->prepare('INSERT INTO nonces (user_id,nonce,timestamp) VALUES (?,?,?)');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $nonce, PDO::PARAM_STR);
			$stmt->bindValue(3, $timestamp, PDO::PARAM_STR);
			$stmt->execute();	
		}
		return true;	
	}
}

?>