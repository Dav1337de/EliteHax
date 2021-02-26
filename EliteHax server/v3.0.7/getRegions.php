<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$last_scans = array_fill(1, 18, 'Never');
		$dcs = array_fill(1, 18, 0);
		$secs_left = array_fill(1, 18, 0);
		$can_scan=1;
		$stmt = $db->prepare("SELECT crew FROM user WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$crew_id=$row['crew'];
		}
		
		$stmt = $db->prepare("SELECT * FROM ((select datacenter.region,count(DISTINCT datacenter.crew_id) as dc,MAX(region_scan.timestamp) as timestamp,TIMESTAMPDIFF(SECOND,MAX(region_scan.timestamp),NOW()) as completed, region_scan.user_id from datacenter JOIN region_scan ON region_scan.region=datacenter.region WHERE region_scan.crew_id=? and datacenter.crew_id<>? and region_scan.timestamp>datacenter.timestamp and region_scan.timestamp IN (SELECT max(timestamp) from region_scan WHERE crew_id=? group by region) group by datacenter.region) UNION (select datacenter.region,0,MAX(region_scan.timestamp),TIMESTAMPDIFF(SECOND,MAX(region_scan.timestamp),NOW()),region_scan.user_id from datacenter JOIN region_scan ON region_scan.region=datacenter.region WHERE region_scan.crew_id=? and region_scan.timestamp<datacenter.timestamp and datacenter.crew_id<>?)) as t group by region"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(3, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(4, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(5, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$region = $row['region'];
			$dc = $row['dc'];
			$timestamp = $row['timestamp'];
			$last_scans[$region] = $timestamp;
			$dcs[$region] = $dc;
			$secs_left[$region] = $row['completed'];
			if (($row['completed']<0) and ($row['user_id']==$id)) {
				$can_scan=0;
			}
		}
		$stmt = $db->prepare("SELECT username,money FROM user WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp="{\n\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"can_scan\": ".$can_scan.",\n";
		}
		
		for ($i = 1; $i <= 18; $i++) {
			$resp = $resp."\"region".$i."_dc\": ".$dcs[$i].",\n"
			."\"region".$i."_scan\": ".$secs_left[$i].",\n"
			."\"region".$i."_timestamp\": \"".$last_scans[$i]."\",\n";
		}
		$resp=$resp."}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>