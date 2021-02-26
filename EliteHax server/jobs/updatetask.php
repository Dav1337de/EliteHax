<?php
	include 'timeandmoney.php';
	include 'db.php';
	//include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
//------
		//SELECT ALL IDs WITH RUNNING TASK
		$stmt = $db->prepare('SELECT DISTINCT id FROM task');
		$stmt->execute();
		$init_arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($init_arr as $rowinit) {
			$db->beginTransaction();
			$id=$rowinit['id'];
			$oc_active=false;
			$interval=0;
			//GET OVERCLOCK
			$stmt = $db->prepare('SELECT overclock.oc_start,overclock.oc_end,TIMESTAMPDIFF(SECOND,NOW(),overclock.oc_end) as oc_interval FROM overclock WHERE overclock.user_id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (!is_null($row['oc_end'])) {
					$oc_active=true;
					$oc_start=strtotime($row['oc_start']);
					$oc_end=strtotime($row['oc_end']);
					$interval=$row['oc_interval'];
				}
				else {
					$oc_active=false;
					$interval=0;
				}
			}
			//IF OVERCLOCK STILL ACTIVE
			if (($oc_active==true) and ($interval>0)) {
				//SELECT TASK THAT ENDS WITH HALF DURATION AND END THEM
				$stmt = $db->prepare("SELECT task.*,NOW() as nowtime,ADDDATE(starttime,INTERVAL (FLOOR(TIMESTAMPDIFF(SECOND,starttime,(SELECT oc_start FROM overclock WHERE user_id=?)))+FLOOR(TIMESTAMPDIFF(SECOND,(SELECT oc_start FROM overclock WHERE user_id=?),endtime)/2)) SECOND) as new_end_time, ADDDATE(starttime, INTERVAL FLOOR(duration/2) SECOND) as new_end_time2 FROM task WHERE id=?");		
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
				$new_points = 0;
				$tot_tasks = $stmt->rowCount();
				$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
				foreach ($arr as $row) {			
					$now = strtotime($row['nowtime']);
					$starttime = strtotime($row['starttime']);
					$new_end_time=strtotime($row['new_end_time']);
					$new_end_time2=strtotime($row['new_end_time2']);
					
					$finished=false;
					//IF OVERCLOCK STARTED BEFORE THE TASK
					if (($starttime-$oc_start)>0) {
						if (($now-$new_end_time2)>=0) { $finished=true; }
					} 
					//IF OVERCLOCK STARTED AFTER THE TASK
					else {
						if (($now-$new_end_time)>=0) { $finished=true; }
					}
					//IF FINISHED
					if ($finished==true) {
						$task_id = $row['task_id'];
						$type = $row['type'];
						$lvl = $row['lvl'];
						//UPDATE UPGRADE
						$stmt = $db->prepare("UPDATE upgrades SET {$type}=? where id=?");
						$stmt->bindValue(1, $row['lvl'], PDO::PARAM_INT);
						$stmt->bindValue(2, $id, PDO::PARAM_INT);
						$stmt->execute();
						//UPDATE SCORE
						$new_points = getPoints($type,$lvl);
						$stmt = $db->prepare("UPDATE user SET score=score+? WHERE id=?");
						$stmt->bindValue(1, $new_points, PDO::PARAM_INT);
						$stmt->bindValue(2, $id, PDO::PARAM_INT);
						$stmt->execute();
						//REMOVE TASK
						$stmt = $db->prepare("DELETE FROM task WHERE task_id=?");
						$stmt->bindValue(1, $task_id, PDO::PARAM_INT);
						$stmt->execute();
					}					
				}
			}
			//IF OVERCLOCK JUST FINISHED
			elseif (($oc_active==true) and ($interval<=0)) {
				$stmt = $db->prepare("SELECT * FROM task where id=? ORDER BY endtime ASC");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
					//CALC HOW MUCH TIME THE OVERCLOCK HAS BEEN ACTIVE
					$starttime = strtotime($row['starttime']);
					$endtime = strtotime($row['endtime']);
					if ($starttime<$oc_start) { $overclock_h=$oc_end-$oc_start; }
					else { $overclock_h=$oc_end-$starttime; }
					if ($overclock_h<0) { $overclock_h=0; }
					//REMOVE THE OVERCLOCK TIME FROM EACH TASK
					$stmt = $db->prepare("UPDATE task SET endtime=starttime+ INTERVAL (duration-({$overclock_h})) SECOND, duration=duration-({$overclock_h}) WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();				
					//DELETE BOOSTER
					$stmt = $db->prepare("DELETE FROM overclock WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
			}
			//NO OVERCLOCK, NORMAL BEHAVIOR
			$stmt = $db->prepare("SELECT task.*,NOW() as nowtime FROM task WHERE (endtime - NOW()) < 1 and id=?");		
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$new_points = 0;
			$tot_tasks = $stmt->rowCount();
			$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
			foreach ($arr as $row) {
				$now = $row['nowtime'];
				$type = $row['type'];
				$lvl = $row['lvl'];
				$stmt = $db->prepare("UPDATE upgrades SET {$type}=? where id=?");
				$stmt->bindValue(1, $row['lvl'], PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				$new_points = getPoints($type,$lvl);
				$stmt = $db->prepare("UPDATE user SET score=score+? WHERE id=?");
				$stmt->bindValue(1, $new_points, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			if ($tot_tasks > 0) {
				$stmt = $db->prepare("DELETE FROM task WHERE (endtime - STR_TO_DATE(?, '%Y-%m-%d %H:%i:%s')) < 1 and id=?");
				$stmt->bindValue(1, $now, PDO::PARAM_STR);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			$db->commit();
		}
	
//------	
	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>