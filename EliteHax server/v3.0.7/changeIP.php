<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT ip_change FROM items WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$ip_change = $row['ip_change'];
		}
		if ($ip_change<1) { exit(); }
		else {
			$ip = mt_rand()+mt_rand();
			$available = false;
			while ($available == false) {
				$stmt = $db->prepare('SELECT id FROM user WHERE ip=?');
				$stmt->bindValue(1, $ip, PDO::PARAM_INT);
				$stmt->execute();	
				if ($stmt->rowCount() == 0) { $available = true; }
				else { $ip = mt_rand()+mt_rand(); }
			}
			$stmt = $db->prepare('UPDATE user SET ip=? WHERE id=?');
			$stmt->bindValue(1, $ip, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare('UPDATE items SET ip_change=ip_change-1 WHERE user_id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		$resp = "{\"status\": \"OK\",\n"
		."\"new_ip\": \"".long2ip($ip)."\",\n"
		."\"ip_change\": ".($ip_change-1)."\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>