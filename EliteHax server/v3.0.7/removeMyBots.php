<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("DELETE FROM botnet WHERE botnet.id IN (SELECT * FROM (SELECT botnet.id FROM botnet JOIN upgrades ON botnet.defense_id = upgrades.id WHERE botnet.defense_id=? and botnet.attacker_malware < (upgrades.av+(upgrades.siem*0.25)+((botnet.attacker_malware/100)*DATEDIFF(NOW(),botnet.timestamp)))) as t)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>