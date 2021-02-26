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
		$stmt = $db->prepare('SELECT token,email FROM register_token WHERE uid=?');
		$stmt->bindValue(1, $uid, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { exit(); }
		else {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$user_token = $row['token'];
				$email = $row['email'];
			}
		}
		//AES256 Decrypt
		$method = 'aes-256-cbc';
		$decrypted = openssl_decrypt ($_POST['data'], $method, $user_token);
		//JSON Decode
		$json = json_decode($decrypted, true);
		$user = trim($json["user"]);
		if (!validateUser($user)) { exit(base64_encode("{\"status\": \"IU\",\n}")); }
		//Check active user and e-mails
		$stmt = $db->prepare('SELECT username FROM user WHERE username=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (strcasecmp($user, $row['username']) == 0) { exit(base64_encode("{\"status\": \"UE\"}")); }
			}
		}
		//Check pending user and e-mails
		$stmt = $db->prepare('SELECT username FROM register_pending WHERE username=?');
		$stmt->bindValue(1, $user, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (strcasecmp($user, $row['username']) == 0) { exit(base64_encode("{\"status\": \"UE\"}")); }
			}
		}
		else {
			//Create the player!	
			//Check IP Availability
			$ip = mt_rand()+mt_rand();
			$available = false;
			while ($available == false) {
				$stmt = $db->prepare('SELECT id FROM user WHERE ip=?');
				$stmt->bindValue(1, $ip, PDO::PARAM_INT);
				$stmt->execute();	
				if ($stmt->rowCount() == 0) { $available = true; }
				else { $ip = mt_rand()+mt_rand(); }
			}
			//Create User
			$money = 10000;
			$score = 0;
			$reputation = 0;
			$stmt = $db->prepare("INSERT INTO user (username, money, score, reputation, ip, creation_time, last_login,crew, crew_role, email, uuid) VALUES (?,?,?,?,?,NOW(),NOW(),0,0,?,MD5(UUID()))");
			$stmt->bindValue(1, $user, PDO::PARAM_STR);
			$stmt->bindValue(2, $money, PDO::PARAM_INT);
			$stmt->bindValue(3, $score, PDO::PARAM_INT);
			$stmt->bindValue(4, $reputation, PDO::PARAM_INT);
			$stmt->bindValue(5, $ip, PDO::PARAM_INT);		
			$stmt->bindValue(6, $email, PDO::PARAM_STR);
			$stmt->execute();	
			//Get ID
			$id = $db->lastInsertId();
			//Create Upgrades, Stats, Notepad, Mission Center
			$stmt = $db->prepare("INSERT INTO upgrades (id) VALUES (?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO user_stats (id) VALUES (?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO items (user_id,small_packs,medium_packs,large_packs,small_oc_packs,overclock) VALUES (?,1,1,1,1,5)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO mission_center (user_id,lvl,upgrade_lvl) VALUES (?,1,0)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO skill_tree (user_id,lvl) VALUES (?,1)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO research (user_id) VALUES (?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO feedback (user_id) VALUES (?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO player_profile (user_id,skin) VALUES (?,'green')");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO achievement (user_id) VALUES (?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO items_pay (user_id) VALUES (?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			//Insert into Tournaments
			$stmt = $db->prepare("INSERT INTO tournament_score_start (id,username,score,crew) VALUES (?,?,0,0)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $user, PDO::PARAM_STR);
			$stmt->execute();
			$stmt = $db->prepare("INSERT INTO tournament_hack (id,username,crew,money_hack,hack_count) VALUES (?,?,0,0,0)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $user, PDO::PARAM_STR);
			$stmt->execute();
			//Delete Pending Register		
			$stmt = $db->prepare('DELETE FROM register_pending WHERE activation_token=?');
			$stmt->bindValue(1, $token, PDO::PARAM_STR);
			$stmt->execute();		
			//Delete Unactivated register pending by email
			$stmt = $db->prepare('DELETE FROM register_pending WHERE email=?');
			$stmt->bindValue(1, $email, PDO::PARAM_STR);
			$stmt->execute();	
			//Delete Unactivated register pending by email
			$stmt = $db->prepare('DELETE FROM register_token WHERE email=?');
			$stmt->bindValue(1, $email, PDO::PARAM_STR);
			$stmt->execute();	
			
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
			$stmt->bindValue(1, $_SERVER['REMOTE_ADDR'], PDO::PARAM_INT);
			$stmt->bindValue(2, $uid, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_STR);
			$stmt->execute();
			$stmt = $db->prepare('UPDATE user_stats SET today_activity=1,current_activity=current_activity+1 WHERE id=? and today_activity=0');
			$stmt->bindValue(1, $id, PDO::PARAM_STR);
			$stmt->execute();			
			$stmt = $db->prepare('UPDATE user_stats SET max_activity=current_activity WHERE id=? and max_activity<current_activity');
			$stmt->bindValue(1, $id, PDO::PARAM_STR);
			$stmt->execute();

			//Send Token
			$expires = new DateTime('now');
			$expires->add(new DateInterval('P30D'));
			$message = json_encode([
				'token' => base64_encode($token),
				'id' => base64_encode($id),
				'expires' => $expires->format('Y-m-d\TH:i:s')
			]);
			$verified_token = base64_encode(hash_hmac('sha256', $message, $hmac_key, true) . $message);
			$resp = "{\n\"status\": \"OK\",\n\"token\": \"".$verified_token."\"\n}";		
		}
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>