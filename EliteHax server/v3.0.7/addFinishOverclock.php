<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//Active Overclock, Overclock Available and Cooling level
		$stmt = $db->prepare("SELECT items.overclock,items.daily_overclock,upgrades.fan,overclock.oc_start,overclock.oc_end FROM items JOIN upgrades ON items.user_id=upgrades.id LEFT JOIN overclock ON upgrades.id=overclock.user_id WHERE items.user_id=?");
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
		}
		if ($overclocks<5) { exit(""); }
		if ($daily_overclock>=15) { exit(base64_encode("{\n\"STATUS\": \"OC_LIMIT\"\n}")); }
		if (($daily_overclock+5)>15) { exit(base64_encode("{\n\"STATUS\": \"OC_LIMIT_FINISH\"\n}")); }
		
		$stmt = $db->prepare("UPDATE task SET endtime=DATE_SUB(endtime,INTERVAL 10 DAY) WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();			
		$stmt = $db->prepare("UPDATE items SET overclock=overclock-5,daily_overclock=daily_overclock+5 WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	
		$overclocks=$overclocks-5;
		$daily_overclock=$daily_overclock+5;

		$resp = "{\n\"STATUS\": \"OK\"\n,\"oc\": ".$overclocks.",\n\"new_daily_oc\": ".$daily_overclock."\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>