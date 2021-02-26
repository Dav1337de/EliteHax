<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['region']))
		exit("An Error occured!");
	$region = $_POST['region'];
	if (!is_numeric($region))
		exit("An Error occured!");
	if (($region<1) or ($region>18))
		exit("An Error occured!");

	try {
		$id = getIdFromToken($db);
		
		//Can Scan
		$can_scan=1;
		$stmt = $db->prepare("SELECT id FROM `datacenter_scan` where user_id=? and timestamp>NOW()");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { $can_scan=0; }
		
		$stmt = $db->prepare("SELECT * FROM ((SELECT datacenter.id,datacenter_scan.user_id,datacenter_scan.difficult,datacenter_scan.wallet,datacenter.crew_id,crew.name,crew.tag,datacenter_scan.timestamp,datacenter.timestamp<datacenter_scan.timestamp as visible,TIMESTAMPDIFF(SECOND,MAX(datacenter_scan.timestamp),NOW()) as completed from datacenter JOIN region_scan ON region_scan.region=datacenter.region JOIN crew ON datacenter.crew_id=crew.id LEFT JOIN datacenter_scan ON datacenter.id = datacenter_scan.datacenter_id WHERE region_scan.crew_id=(SELECT crew FROM user WHERE id=?) and region_scan.timestamp>datacenter.timestamp and region_scan.region=? and datacenter.crew_id<>(SELECT crew FROM user WHERE id=?) and (datacenter_scan.id IN (SELECT MAX(id) FROM datacenter_scan WHERE crew_id=(SELECT crew FROM user WHERE id=?) GROUP BY datacenter_id) or datacenter_scan.id is null) group by datacenter.id order by rand()) UNION (SELECT datacenter.id,datacenter_scan.user_id,datacenter_scan.difficult,datacenter_scan.wallet,datacenter.crew_id,crew.name,crew.tag,datacenter_scan.timestamp,null as visible,null as completed from datacenter JOIN region_scan ON region_scan.region=datacenter.region JOIN crew ON datacenter.crew_id=crew.id LEFT JOIN datacenter_scan ON datacenter.id = datacenter_scan.datacenter_id WHERE region_scan.crew_id=(SELECT crew FROM user WHERE id=?) and region_scan.timestamp>datacenter.timestamp and region_scan.region=? and datacenter.crew_id<>(SELECT crew FROM user WHERE id=?) group by datacenter.id order by rand())) as t group by id"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $region, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, $id, PDO::PARAM_INT);
		$stmt->bindValue(5, $id, PDO::PARAM_INT);
		$stmt->bindValue(6, $region, PDO::PARAM_INT);
		$stmt->bindValue(7, $id, PDO::PARAM_INT);
		$stmt->execute();
		$dcs = $stmt->rowCount();
		if ($dcs>0) {
			$dc_id = array_fill(1, $dcs, 0);
			$dc_names = array_fill(1, $dcs, '????????');
			$dc_tags = array_fill(1, $dcs, '?????');
			$dc_wallet = array_fill(1, $dcs, '?????');
			$last_scans = array_fill(1, $dcs, 'Never');
			$last_attack = array_fill(1, $dcs, 'Never');
			$next_attack = array_fill(1, $dcs, 0);
			$secs_left = array_fill(1, $dcs, 0);
			$dc_difficult = array_fill(1, $dcs, 0);
			$i=1;
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				
				$dc_id[$i]=$row['id'];				
				$dc_visible = $row['visible'];
				$secs_left[$i] = $row['completed'];
				if (($row['completed']<0)) {
					$last_scans[$i]=$row['completed'];
				}
				if ($dc_visible=="1") {
					//Name, TAG, Difficult, Last Scan
					$dc_names[$i]=$row['name'];
					$dc_tags[$i]=$row['tag'];
				}
				if (($dc_visible=="1") and ($row['completed']>=0)) {
					if ($row['difficult']<4) {
						$dc_wallet[$i]=$row['wallet'];
					}
					$dc_difficult[$i]=$row['difficult'];
					$last_scans[$i]=$row['timestamp'];
				}
				//Last Attack
				$stmt2 = $db->prepare("SELECT timestamp,TIMESTAMPDIFF(SECOND,DATE_ADD(timestamp,INTERVAL 1 DAY),NOW()) as next_attack FROM datacenter_attack_logs WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=? and mf_hack='y' order by timestamp desc limit 1"); 
				$stmt2->bindValue(1, $id, PDO::PARAM_INT);
				$stmt2->bindValue(2, $dc_id[$i], PDO::PARAM_INT);
				$stmt2->execute();
				while($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {
					$last_attack[$i]=$row2['timestamp'];
					$next_attack[$i]=$row2['next_attack'];
				}
				$i++;
			}
		}
		$stmt = $db->prepare("SELECT username,money FROM user WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp="{\n\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"dcs\": ".$dcs.",\n"
			."\"can_scan\": ".$can_scan.",\n";
		}
		
		for ($i = 1; $i <= $dcs; $i++) {
			$resp = $resp."\"dc".$i."_id\": ".$dc_id[$i].",\n"
			."\"dc".$i."_name\": \"".$dc_names[$i]."\",\n"
			."\"dc".$i."_tag\": \"".$dc_tags[$i]."\",\n"
			."\"dc".$i."_wallet\": \"".$dc_wallet[$i]."\",\n"
			."\"dc".$i."_difficult\": \"".$dc_difficult[$i]."\",\n"
			."\"dc".$i."_last_attack\": \"".$last_attack[$i]."\",\n"
			."\"dc".$i."_next_attack\": \"".$next_attack[$i]."\",\n"
			."\"dc".$i."_timestamp\": \"".$last_scans[$i]."\",\n";
		}
		$resp=$resp."}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>