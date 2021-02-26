<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		
		sleep(10);
		
		$today = date("Ymd");
		$stmt = $db->prepare("CREATE TABLE attacks{$today} SELECT attack_log.attacker_id,user.username,HOUR(timestamp) as hour, count(attack_log.id) as attacks FROM attack_log JOIN user ON attack_log.attacker_id = user.id WHERE DATE_SUB(NOW(),INTERVAL 24 HOUR) <= timestamp GROUP BY HOUR(attack_log.timestamp), attacker_id ORDER BY HOUR(timestamp),count(attack_log.id) DESC");		
		$stmt->execute();
		
		$stmt = $db->prepare("CREATE TABLE economy{$today} SELECT * FROM economy");		
		$stmt->execute();
		
		$stmt = $db->prepare("DELETE FROM economy");		
		$stmt->execute();		
		
		$stmt = $db->prepare("INSERT INTO economy (user_id) SELECT id FROM user");		
		$stmt->execute();

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>