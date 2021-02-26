<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("DELETE FROM rat WHERE rat.id IN (SELECT * FROM (SELECT rat.id FROM rat JOIN upgrades ON rat.defense_id = upgrades.id WHERE rat.defense_id=? and rat.attacker_malware < (upgrades.av+(upgrades.siem*0.25)+((rat.attacker_malware/100)*DATEDIFF(NOW(),rat.timestamp)))) as t)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>