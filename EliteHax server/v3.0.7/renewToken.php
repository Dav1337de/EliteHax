<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$uid="NONE";
		if (isset($_POST['deviceid'])) {
			$uid = base64_decode($_POST['deviceid']);
		}
		if (!validateDeviceID($db,$uid)) { exit(); }
		
		//CloudFlare Real IP
		$source_ip=$_SERVER['REMOTE_ADDR'];
		if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
		  $source_ip = $_SERVER["HTTP_CF_CONNECTING_IP"];
		}
		
		//Delete Old Player Token
		$stmt = $db->prepare('DELETE FROM player_token WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
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
		$stmt = $db->prepare('UPDATE user SET last_login=NOW(),login_ip=?, device_id=? WHERE id=?');
		$stmt->bindValue(1, $source_ip, PDO::PARAM_STR);
		$stmt->bindValue(2, $uid, PDO::PARAM_STR);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
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
			//GitHub Note: You need to put your proxycheck.io key
			$ip_json = file_get_contents('http://proxycheck.io/v2/' . $source_ip . "?key=<ProxyCheckIOKey>" . "&vpn=1" . "&tag=ac", true);
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
		$user_timezone = 0;
		$user_country = "None";
		$user_lang = "None";
		if (isset($_POST['env'])) { 
			$env = base64_decode($_POST['env']);
			$json = json_decode($env, true);
			$user_timezone = $json["tz"];
			$user_country = $json['country'];
			$user_lang = $json['lang'];
		}
		if($query && $query['status'] == 'success') {
			$stmt = $db->prepare('INSERT INTO login_audit (user_id, ip, device_id, timestamp, country, region, city, timezone, isp, user_timezone, user_country, user_lang, anon) VALUES (?,?,?,NOW(),?,?,?,?,?,?,?,?,?)');
			$stmt->bindValue(1, $id, PDO::PARAM_STR);
			$stmt->bindValue(2, $source_ip, PDO::PARAM_STR);
			$stmt->bindValue(3, $uid, PDO::PARAM_STR);
			$stmt->bindValue(4, $query['countryCode'], PDO::PARAM_STR);
			$stmt->bindValue(5, $query['regionName'], PDO::PARAM_STR);
			$stmt->bindValue(6, $query['city'], PDO::PARAM_STR);
			$stmt->bindValue(7, $query['timezone'], PDO::PARAM_STR);
			$stmt->bindValue(8, $query['isp'], PDO::PARAM_STR);
			$stmt->bindValue(9, $user_timezone, PDO::PARAM_STR);
			$stmt->bindValue(10, $user_country, PDO::PARAM_STR);
			$stmt->bindValue(11, $user_lang, PDO::PARAM_STR);
			$stmt->bindValue(12, $ip_status, PDO::PARAM_STR);
			$stmt->execute();		
		}
		
		if ($ip_status=="anon") {
			exit(base64_encode("{\n\"ANON\": \"Y\"\n}"));
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
		$resp = "{\n\"status\": \"OK\",\n\"token\": \"".$verified_token."\"\n}";		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>