<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	if (!isset($_POST['mission_id'])) { exit(); }
	$mission_id = $_POST['mission_id'];
	try {
		$id = getIdFromToken($db);
		
		//Running missions & Mission Center Lvl
		$stmt = $db->prepare("SELECT mission_center.lvl,t.running_missions from (SELECT COALESCE(sum(missions_available.running),0) as running_missions FROM missions_available WHERE missions_available.user_id=? and (NOW()-missions_available.time_finish) <0) as t,mission_center WHERE mission_center.user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$running_missions = $row['running_missions'];
			$mission_center_lvl = $row['lvl'];
			if ($running_missions >= max_missions($mission_center_lvl)) { 
				$resp = "{\n\"STATUS\": \"MAX_CC\"\n}";
				exit(base64_encode($resp));	
			}
		}
				
		$stmt = $db->prepare("SELECT duration FROM `missions_available` WHERE user_id=? and id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $mission_id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { exit(); }
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$time = $row['duration'];
			$stmt = $db->prepare("UPDATE missions_available SET running=1,time_start=NOW(),time_finish=(NOW() + INTERVAL {$time} MINUTE) WHERE id=?");
			$stmt->bindValue(1, $mission_id, PDO::PARAM_INT);
			$stmt->execute();
			$resp = "{\n\"STATUS\": \"OK\"\n,\"secs\": ".(60*$time)."\n}";
		}
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>