<?php
	include 'db.php';
	include 'validate.php';
	if ((!isset($_POST['type'])) or (!isset($_POST['lvl']))) { exit(); }
	try {
		$type=$_POST['type'];
		$lvl=$_POST['lvl'];
		$id = getIdFromToken($db);
		//Get Tasks
		$stmt = $db->prepare("SELECT type,lvl,TIMESTAMPDIFF(second,NOW(),endtime) as finished FROM `task` WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		//Check Abort
		$canAbort=true;
		$exists=false;
		$isFinished=false;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$curType=$row['type'];
			$curLvl=$row['lvl'];
			$finished=$row['finished'];
			if (($curType==$type) and ($curLvl>$lvl)) {
				$canAbort=false;
			}
			if (($curType==$type) and ($curLvl==$lvl)) {
				$exists=true;
				if ($fnished<=0) { $ifFinished=true; }
			}
		}
		if (($exists==false) or ($canAbort==false)) { exit(); }

		//Check Tournament Active
		$stmt = $db->prepare("SELECT tournaments_new.type FROM `tournaments_new` WHERE CURTIME()>time_start ORDER BY time_start desc LIMIT 1");
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$current = $row['type'];
		}
		if (($current==1) or ($current==3)) {
			$resp = "{\n\"status\": \"TOURNAMENT_ACTIVE\"\n}";
			exit(base64_encode($resp));
		}
		
		if ($canAbort==true) {
			
			//Check Abort Hourly Limit
			$stmt = $db->prepare("SELECT COUNT(task_abort.id) as abort_n,ram FROM `task_abort` JOIN upgrades ON user_id=upgrades.id WHERE user_id=? and DATE_SUB(NOW(),INTERVAL 1 DAY) <= timestamp");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$ram=$row['ram'];
				$abort_n=$row['abort_n'];
				if ($abort_n >= ($ram+6)) {
					$resp = "{\n\"status\": \"MAX_ABORT\"\n}";
					exit(base64_encode($resp));	
				}
			}
			//Abort
			$stmt = $db->prepare("DELETE FROM task WHERE id=? and type=? and lvl=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $type, PDO::PARAM_STR);
			$stmt->bindValue(3, $lvl, PDO::PARAM_INT);
			$stmt->execute();		
			$typet = $type."_task";
			$stmt = $db->prepare("UPDATE upgrades SET {$typet}={$typet}-1 WHERE id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();	
			$stmt = $db->prepare("INSERT INTO task_abort (user_id,timestamp) VALUES (?,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();			
		}
		
		$resp = "{\n\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>