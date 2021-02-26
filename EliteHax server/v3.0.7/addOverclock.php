<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//Active Overclock, Overclock Available and Cooling level
		$stmt = $db->prepare("SELECT items.overclock,items.daily_overclock,upgrades.fan,overclock.oc_start,overclock.oc_end,research.coolR1,TIMESTAMPDIFF(SECOND,NOW(),oc_end) as finish FROM items JOIN upgrades ON items.user_id=upgrades.id JOIN research ON items.user_id=research.user_id LEFT JOIN overclock ON upgrades.id=overclock.user_id WHERE items.user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$overclocks=$row['overclock'];
			$daily_overclock=$row['daily_overclock'];
			$cooling = $row['fan'];
			$oc_start = $row['oc_start'];
			$oc_end = $row['oc_end'];
			$endtime = strtotime($row['oc_end']);
			$coolR1 = $row['coolR1'];
			$finish=$row['finish'];
		}
		if ($overclocks<1) { exit(""); }
		if ($daily_overclock>=15) { exit(base64_encode("{\n\"STATUS\": \"OC_LIMIT\"\n}")); }
		
		//Overclock Duration based on Cooling
		$new_oc_time=(60+(12*$cooling))*60+(30*$coolR1);
		if ($finish<0) {
			$stmt = $db->prepare("DELETE FROM overclock WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//No overclock running
		if (is_null($oc_start) or ($finish<0)) {
			$stmt = $db->prepare("INSERT INTO overclock (user_id,oc_start,oc_end) VALUES (?,NOW(),NOW() + INTERVAL {$new_oc_time} SECOND)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$interval=$new_oc_time;
		} else {
		//Overclock Running
			$stmt = $db->prepare("UPDATE overclock SET oc_end=oc_end + INTERVAL {$new_oc_time} SECOND WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();	
			$stmt = $db->prepare("SELECT TIMESTAMPDIFF(SECOND,NOW(),oc_end) as o_interval from overclock WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();	
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$interval = $row['o_interval'];
			}
		}
		$stmt = $db->prepare("UPDATE items SET overclock=overclock-1,daily_overclock=daily_overclock+1 WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	
		$overclocks=$overclocks-1;
		$daily_overclock=$daily_overclock+1;

		$resp = "{\n\"STATUS\": \"OK\"\n,\"secs\": ".$interval."\n,\"oc\": ".$overclocks.",\n\"new_daily_oc\": ".$daily_overclock."\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>