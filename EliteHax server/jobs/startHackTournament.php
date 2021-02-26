<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		//Player Tables
		$stmt = $db->prepare("DELETE FROM tournament_hack");		
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO tournament_hack (id,username,crew,money_hack,hack_count) SELECT id,username,crew,0,0 from user");		
		$stmt->execute();
		
		//GitHub Note: Send Push Notification for tournament start
		$response = sendMessage("XXX"); //Message ID from OneSignal

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>