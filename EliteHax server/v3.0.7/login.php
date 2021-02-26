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
		$stmt = $db->prepare('DELETE FROM login_token WHERE (expire - NOW()) < 1');
		$stmt->execute();
		$stmt = $db->prepare('SELECT token FROM login_token WHERE uid=?');
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
		if (!validateUser($user)) { exit(); }
		
		//CloudFlare Real IP
		$source_ip=$_SERVER['REMOTE_ADDR'];
		if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
		  $source_ip = $_SERVER["HTTP_CF_CONNECTING_IP"];
		}
		
		//Check Failed Logins
		$stmt = $db->prepare('SELECT id,(NOW()-timestamp) as diff FROM login_failed WHERE (username=? or ip=?) and (NOW()-timestamp) <= 900 order by timestamp DESC');
		$stmt->bindValue(1, $user, PDO::PARAM_STR);
		$stmt->bindValue(2, $source_ip, PDO::PARAM_STR);
		$stmt->execute();		
		$failed_attempts = $stmt->rowCount();
		if ($stmt->rowCount() >= 5) { 
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$last_failed = $row['diff'];
			if ($last_failed <= 900) {
				exit(base64_encode("{\n\"status\": \"TME\"\n}"));
			}				
		}
		
		//Check if user exists
		$stmt = $db->prepare('SELECT id,password FROM user WHERE username=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { $resp = "{\n\"status\": \"KO\"\n}"; }
		else {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$stored_password = $row['password'];
				$id = $row['id'];
			}
			if (password_verify(base64_encode(hash('sha256', $password, true)),$stored_password)) {
				//Check Ban Warning
				$ban_warning="N";
				$ban_reason="";
				$stmt = $db->prepare('SELECT * FROM ban_warning WHERE user_id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->execute();	
				if ($stmt->rowCount() != 0) { 
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
						$ban_warning = "Y";
						$ban_reason = $row["reason"];
					}
				}				
				//Check Ban
				$stmt = $db->prepare('SELECT * FROM ban_user WHERE user_id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->execute();	
				if ($stmt->rowCount() != 0) { 
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
						$reason = $row["reason"];
					}
					exit(base64_encode("{\n\"status\": \"BAN\",\n\"reason\": \"".$reason."\"\n}"));
				}
				//Delete Login Token
				$stmt = $db->prepare('DELETE FROM login_token WHERE uid=?');
				$stmt->bindValue(1, $uid, PDO::PARAM_INT);
				$stmt->execute();
				//Delete Old Player Token
				$stmt = $db->prepare('DELETE FROM player_token WHERE id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				//Player Token
				$token_length = 16;
				$hmac_length = 128;
				$token = bin2hex(random_bytes($token_length));
				$hmac_key = bin2hex(random_bytes($hmac_length));
				$stmt = $db->prepare('INSERT INTO player_token (id, token, hmac, expire) VALUES (?,?,?,NOW()+INTERVAL 30 DAY)');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $token, PDO::PARAM_STR);
				$stmt->bindValue(3, $hmac_key, PDO::PARAM_STR);
				$stmt->execute();
				
				//Update Daily Statistics
				$stmt = $db->prepare('UPDATE user SET last_login=NOW(), login_ip=?, device_id=? WHERE id=?');
				$stmt->bindValue(1, $source_ip, PDO::PARAM_INT);
				$stmt->bindValue(2, $uid, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_STR);
				$stmt->execute();
				$stmt = $db->prepare('UPDATE user_stats SET today_activity=1,current_activity=current_activity+1 WHERE id=? and today_activity=0');
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->execute();			
				$stmt = $db->prepare('UPDATE user_stats SET max_activity=current_activity WHERE id=? and max_activity<current_activity');
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->execute();
				
				//IP Reputation
				//Check Local Cache
				$ip_status="clear";
				$stmt = $db->prepare('SELECT status FROM ip_reputation WHERE ip=? and TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(timestamp,INTERVAL 3 DAY))>0');
				$stmt->bindValue(1, $source_ip, PDO::PARAM_STR);
				$stmt->execute();
				if ($stmt->rowCount() != 0) { 
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
						$ip_status=$row['status'];
					}	
				}
				//Query proxycheck.io
				else {
					//GitHub Note: You need to put your ProxyCheckIO key
					$ip_json = file_get_contents('http://proxycheck.io/v2/' . $source_ip . "?key=<ProxyCheckIO>" . "&vpn=1" . "&tag=ac", true);
					$ip_json_decoded = json_decode($ip_json);
					
					if (($ip_json_decoded) and (($ip_json_decoded->status=='ok') or ($ip_json_decoded->status == 'warning'))) {
						if ( $ip_json_decoded->$source_ip->proxy == "yes" ) {
							$ip_status="anon";
						}
						else {
							$ip_status="clear";
						}
						$stmt = $db->prepare('REPLACE into ip_reputation (ip, status, timestamp) values(?, ?, NOW())');
						$stmt->bindValue(1, $source_ip, PDO::PARAM_STR);
						$stmt->bindValue(2, $ip_status, PDO::PARAM_STR);
						$stmt->execute();		
					}
				}
				
				//IP Geolocation
				$query = @unserialize(file_get_contents('http://ip-api.com/php/'.$source_ip));
				if($query && $query['status'] == 'success') {
					$stmt = $db->prepare('INSERT INTO login_audit (user_id, ip, device_id, timestamp, country, region, city, timezone, isp, anon) VALUES (?,?,?,NOW(),?,?,?,?,?,?)');
					$stmt->bindValue(1, $id, PDO::PARAM_STR);
					$stmt->bindValue(2, $source_ip, PDO::PARAM_STR);
					$stmt->bindValue(3, $uid, PDO::PARAM_STR);
					$stmt->bindValue(4, $query['countryCode'], PDO::PARAM_STR);
					$stmt->bindValue(5, $query['regionName'], PDO::PARAM_STR);
					$stmt->bindValue(6, $query['city'], PDO::PARAM_STR);
					$stmt->bindValue(7, $query['timezone'], PDO::PARAM_STR);
					$stmt->bindValue(8, $query['isp'], PDO::PARAM_STR);
					$stmt->bindValue(9, $ip_status, PDO::PARAM_STR);
					$stmt->execute();		
				}
				
				if ($ip_status=="anon") {
					exit(base64_encode("{\n\"status\": \"ANON\"\n}"));
				}

				//Send Token
				$expires = new DateTime('now');
				$expires->add(new DateInterval('P30D'));
				$message = json_encode([
					'token' => base64_encode($token),
					'id' => base64_encode($id),
					'expires' => $expires->format('Y-m-d\TH:i:s')
				]);
				$verified_token = base64_encode(hash_hmac('sha256', $message, $hmac_key, true) . $message);
				$resp = "{\n\"status\": \"OK\",\n\"token\": \"".$verified_token."\",\n\"BAN_WARNING\": \"".$ban_warning."\",\n\"BAN_REASON\": \"".$ban_reason."\"\n}";
				//DELETE FAILED LOGINS
				$stmt = $db->prepare('DELETE FROM login_failed WHERE username=? or ip=?');
				$stmt->bindValue(1, $user, PDO::PARAM_STR);
				$stmt->bindValue(2, $source_ip, PDO::PARAM_STR);
				$stmt->execute();	
			}		
			else {
				sleep($failed_attempts);
				$stmt = $db->prepare('INSERT INTO login_failed (username, ip, timestamp) VALUES (?,?,NOW())');
				$stmt->bindValue(1, $user, PDO::PARAM_STR);
				$stmt->bindValue(2, $source_ip, PDO::PARAM_STR);
				$stmt->execute();				
				$resp = "{\n\"status\": \"KO\"\n}";
			}
		}
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>