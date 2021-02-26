<?php
include 'db.php';
include 'validate.php';
	try {
		if (!isset($_GET['code'])) { exit("CODE MISSING"); }
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
		$stmt = $db->prepare('SELECT * FROM register_pending WHERE email=? and activation_token=?');
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
		$stmt = $db->prepare("INSERT INTO user (username, money, score, reputation, ip, creation_time, last_login,crew, crew_role, email, password, uuid) VALUES (?,?,?,?,?,NOW(),NOW(),0,0,?,?,MD5(UUID()))");
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $money, PDO::PARAM_INT);
		$stmt->bindValue(3, $score, PDO::PARAM_INT);
		$stmt->bindValue(4, $reputation, PDO::PARAM_INT);
		$stmt->bindValue(5, $ip, PDO::PARAM_INT);		
		$stmt->bindValue(6, $email, PDO::PARAM_STR);
		$stmt->bindValue(7, $password, PDO::PARAM_STR);
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
		$stmt = $db->prepare("INSERT INTO items_pay (user_id) VALUES (?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO player_profile (user_id,skin) VALUES (?,'green')");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO achievement (user_id) VALUES (?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		//Insert into Tournaments
		$stmt = $db->prepare("INSERT INTO tournament_score_start (id,username,score,crew) VALUES (?,?,0,0)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $username, PDO::PARAM_STR);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO tournament_hack (id,username,crew,money_hack,hack_count) VALUES (?,?,0,0,0)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $username, PDO::PARAM_STR);
		$stmt->execute();
		//Delete Pending Register		
		$stmt = $db->prepare('DELETE FROM register_pending WHERE activation_token=?');
		$stmt->bindValue(1, $token, PDO::PARAM_STR);
		$stmt->execute();		
	} catch(PDOException $ex) {
		exit("Error: ".$ex);
	}
?>
<!DOCTYPE html>
<html>
<body>
<h1>Welcome to EliteHax!</h1>
<p>Activation completed! Close and open your app again to login.</p>
</body>
</html>