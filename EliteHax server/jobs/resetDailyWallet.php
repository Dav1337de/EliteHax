<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);

		//Current Activity reset for inactive
		$stmt = $db->prepare("UPDATE user_stats SET current_activity=0 WHERE today_activity = 0");		
		$stmt->execute();
		//Reset Today Activity
		$stmt = $db->prepare("UPDATE user_stats SET today_activity=0 WHERE today_activity != 0");		
		$stmt->execute();
		//Reset Today Reward
		$stmt = $db->prepare("UPDATE user_stats SET today_reward=0 WHERE today_reward != 0");		
		$stmt->execute();
		//Reset Today Overclocks
		$stmt = $db->prepare("UPDATE items SET daily_overclock=0 WHERE daily_overclock != 0");		
		$stmt->execute();	
		
		sleep(1);
		
		$db->beginTransaction();
		$stmt = $db->prepare("UPDATE crew SET daily_wallet=0 WHERE daily_wallet != 0");		
		$stmt->execute();
		
		sleep(1);
		
		$stmt = $db->prepare("UPDATE user SET crew_daily_contribution=0 WHERE crew_daily_contribution != 0");		
		$stmt->execute();
		$db->commit();
		
		sleep(1);
		
		$stmt = $db->prepare("UPDATE datacenter SET cpoints=0 WHERE cpoints != 0");		
		$stmt->execute();
		$db->commit();

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>