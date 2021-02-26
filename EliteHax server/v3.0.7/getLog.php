<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("UPDATE attack_log SET seen=1 WHERE defense_id=? and seen=0");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("SELECT siem FROM upgrades WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$siem=$row['siem'];
		}
		$logs=20+floor($siem/250);
		if ($logs>30) { $logs=30; }
		
		$stmt = $db->prepare("SELECT attack_log.*,DATE_SUB(timestamp,INTERVAL 60 MINUTE) as timestamp,a.ip as a_ip,d.ip as d_ip FROM attack_log JOIN user as a ON a.id = attack_log.attacker_id JOIN user as d ON d.id=attack_log.defense_id where attacker_id=? or defense_id=? ORDER BY timestamp DESC LIMIT {$logs}");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"logs\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$anon = $row['anon'];
			$attacker = long2ip($row['a_ip']);
			$defense = long2ip($row['d_ip']);
			$result = $row['result'];
			if ($anon == 1) { $attacker = "Anonymous"; }
			if ($row['attacker_id'] == $id) { $attacker = "You"; }
			if ($row['defense_id'] == $id) { $defense = "You"; }
			
			if (($attacker == "You") and ($result == 1)) { $rep_change = "+".$row['rep_change']; }
			if (($attacker == "You") and ($result == 0)) { $rep_change = $row['rep_change']; }
			if (($defense == "You") and ($result == 1)) { $rep_change = "-".($row['rep_change']); }
			if (($defense == "You") and ($result == 0)) { $rep_change = "+".(abs($row['rep_change'])); }
			
			$timestamp = strtotime($row['timestamp']);
			$resp = $resp
			."{\"type\": \"".$row['type']."\",\n"
			."\"result\": ".$row['result'].",\n"
			."\"attacker\": \"".$attacker."\",\n"
			."\"defense\": \"".$defense."\",\n"
			."\"money_stolen\": ".$row['money_stolen'].",\n"
			."\"rep_change\": \"".$rep_change."\",\n"
			."\"timestamp\": \"".$row['timestamp']."\"\n},";
		}
		$resp = $resp."],\n";
		$stmt = $db->prepare('SELECT username,money FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"user\": \"".$row['username']."\",\n"		
			."\"money\": ".$row['money']."\n}";			
		}		
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>