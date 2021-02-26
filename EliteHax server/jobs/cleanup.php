<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		//DELETE Nonces - 1 Day
		$stmt = $db->prepare("DELETE FROM nonces WHERE from_unixtime(timestamp)<DATE_SUB(NOW(),INTERVAL 1 DAY)");		
		$stmt->execute();
		
		//DELETE Attack Logs - 7 Days
		$stmt = $db->prepare("DELETE FROM `attack_log` where timestamp<DATE_SUB(NOW(),INTERVAL 7 DAY)");		
		$stmt->execute();
		
		//DELETE Bot Attempts - 7 Days
		$stmt = $db->prepare("DELETE FROM bot_attempt where timestamp<DATE_SUB(NOW(),INTERVAL 7 DAY)");		
		$stmt->execute();

		//DELETE Rewards - 30 Days
		$stmt = $db->prepare("DELETE FROM rewards where timestamp<DATE_SUB(NOW(),INTERVAL 30 DAY)");		
		$stmt->execute();
		
		//DELETE Task Abort - 30 Days
		$stmt = $db->prepare("DELETE FROM task_abort where timestamp<DATE_SUB(NOW(),INTERVAL 30 DAY)");		
		$stmt->execute();		
		
		//DELETE Datacenter Attack Logs - 30 Days
		$stmt = $db->prepare("DELETE FROM datacenter_attack_logs where timestamp<DATE_SUB(NOW(),INTERVAL 30 DAY)");		
		$stmt->execute();	
		
		//DELETE Expired Registrations - 90 Days
		$stmt = $db->prepare("DELETE FROM register_pending WHERE token_expire<DATE_SUB(NOW(),INTERVAL 90 DAY)");		
		$stmt->execute();	
		
		//DELETE Research Audit - 60 Days
		$stmt = $db->prepare("DELETE FROM research_audit where timestamp<DATE_SUB(NOW(),INTERVAL 60 DAY)");		
		$stmt->execute();	

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>