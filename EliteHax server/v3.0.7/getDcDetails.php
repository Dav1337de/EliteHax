<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['dc']))
		exit("An Error occured!");
	$dc = $_POST['dc'];
	if (!is_numeric($dc))
		exit("An Error occured!");

	try {
		$id = getIdFromToken($db);
		
		//Check if datacenter has been scanned
		$stmt = $db->prepare("SELECT DISTINCT datacenter_id FROM `datacenter_scan` WHERE crew_id=(SELECT crew FROM user WHERE id=?) and TIMESTAMPDIFF(SECOND,timestamp,NOW())>0 and datacenter_id=? and region=(SELECT region FROM datacenter WHERE id=?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->bindValue(3, $dc, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
		
		//Last Attack > 0 and Completed = 1 -> Reset!
		$stmt2 = $db->prepare("SELECT timestamp,TIMESTAMPDIFF(SECOND,DATE_ADD(timestamp,INTERVAL 5 DAY),NOW()) as next_attack,completed FROM datacenter_attack_logs JOIN datacenter_attacks ON datacenter_attack_logs.attacking_crew=datacenter_attacks.attacking_crew and datacenter_attack_logs.datacenter_id=datacenter_attacks.datacenter_id WHERE datacenter_attacks.attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_attacks.datacenter_id=? and mf_hack='y' order by timestamp desc limit 1"); 
		$stmt2->bindValue(1, $id, PDO::PARAM_INT);
		$stmt2->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt2->execute();
		while($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {
			$next_attack=$row2['next_attack'];
			$completed=$row2['completed'];
		}
		if (($next_attack>0) and ($completed==1)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext=0,fwext_detected=0,ips=0,ips_detected=0,siem=0,siem_detected=0,fwint1=0,fwint1_detected=0,fwint2=0,fwint2_detected=0,mf1=0,mf1_detected=0,mf2=0,mf2_detected=0,completed=0 WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $dc, PDO::PARAM_INT);
			$stmt->execute();
		}			
		
		//My Stats
		$stmt = $db->prepare("SELECT scanner,anon,exploit FROM `datacenter_upgrades` WHERE datacenter_id=(SELECT id FROM datacenter WHERE crew_id=(SELECT crew FROM user WHERE id=?))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_scanner = $row['scanner'];
			$my_anon = $row['anon'];
			$my_exploit = $row['exploit'];
		}
		
		//Attack Status	
		$stmt = $db->prepare("SELECT * FROM `datacenter_attacks` where attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) {
			$first_attack=1;
			$fwext_as=0;
			$ips_as=0;
			$siem_as=0;
			$fwint1_as=0;
			$fwint2_as=0;
			$mf1_as=0;
			$mf2_as=0;	
		}
		else {
			$first_attack=0;
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$fwext_as=$row['fwext'];
				$ips_as=$row['ips'];
				$siem_as=$row['siem'];
				$fwint1_as=$row['fwint1'];
				$fwint2_as=$row['fwint2'];
				$mf1_as=$row['mf1'];
				$mf2_as=$row['mf2'];
			}			
		}
		
		//Target Stats
		$stmt = $db->prepare("SELECT name,fwext,ips,siem,fwint1,fwint2,mf1,mf2 FROM `datacenter_upgrades` JOIN datacenter ON datacenter_upgrades.datacenter_id=datacenter.id JOIN crew ON datacenter.crew_id=crew.id WHERE datacenter_id=?");
		$stmt->bindValue(1, $dc, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_name = $row['name'];
			$fwext = $row['fwext'];
			$siem = $row['siem'];
			$ips = $row['ips'];
			$fwint1 = $row['fwint1'];
			$fwint2 = $row['fwint2'];
			$mf1 = $row['mf1'];
			$mf2 = $row['mf2'];
		}
		
		//Level, Anon %, Attack %
		$fwext_lvl="???";
		$fwext_anon_c="???";
		$fwext_attack_c="???";
		$ips_lvl="???";
		$ips_anon_c="???";
		$ips_attack_c="???";
		$siem_lvl="???";
		$siem_anon_c="???";
		$siem_attack_c="???";
		$fwint1_lvl="???";
		$fwint1_anon_c="???";
		$fwint1_attack_c="???";
		$fwint2_lvl="???";
		$fwint2_anon_c="???";
		$fwint2_attack_c="???";
		$mf1_lvl="???";
		$mf1_anon_c="???";
		$mf1_attack_c="???";
		$mf2_lvl="???";
		$mf2_anon_c="???";
		$mf2_attack_c="???";
		
		//fwext
		$difficult_p=$my_scanner/$fwext*100;
		if ($difficult_p>=50) { 
			$fwext_lvl=$fwext; 
			$fwext_anon_c = floor(($my_anon*100)/(($fwext+$siem)*0.5));
			if ($fwext_anon_c>100) { $fwext_anon_c=100; }
			$fwext_attack_c = floor(($my_exploit*125)/$fwext);
			if ($fwext_attack_c>95) { $fwext_attack_c=95; }
		}
		
		//ips
		if ($fwext_as==3) {
			$difficult_p=$my_scanner/$ips*100;
			if ($difficult_p>=75) { 
				$ips_lvl=$ips; 
				$ips_anon_c = floor(($my_anon*100)/(($ips+$siem)*0.75));
				if ($ips_anon_c>100) { $ips_anon_c=100; }
				$ips_attack_c = floor(($my_exploit*100)/$ips);
				if ($ips_attack_c>95) { $ips_attack_c=95; }
			}
		}
		
		//siem
		if ($ips_as==3) {
			$difficult_p=$my_scanner/$siem*100;
			if ($difficult_p>=100) { 
				$siem_lvl=$siem; 
				$siem_anon_c = floor(($my_anon*100)/(($siem+$siem)*1));
				if ($siem_anon_c>100) { $siem_anon_c=100; }
				$siem_attack_c = floor(($my_exploit*80)/$siem);
				if ($siem_attack_c>95) { $siem_attack_c=95; }
			}
		}
		
		//fwint1
		if ($ips_as==3) {
			$difficult_p=$my_scanner/$fwint1*100;
			if ($difficult_p>=100) { 
				$fwint1_lvl=$fwint1; 
				$fwint1_anon_c = floor(($my_anon*100)/(($fwint1+$siem)*1));
				if ($fwint1_anon_c>100) { $fwint1_anon_c=100; }
				$fwint1_attack_c = floor(($my_exploit*80)/$fwint1);
				if ($fwint1_attack_c>95) { $fwint1_attack_c=95; }
			}
		}
		
		//fwint2
		if ($ips_as==3) {
			$difficult_p=$my_scanner/$fwint2*100;
			if ($difficult_p>=100) { 
				$fwint2_lvl=$fwint2; 
				$fwint2_anon_c = floor(($my_anon*100)/(($fwint2+$siem)*1));
				if ($fwint2_anon_c>100) { $fwint2_anon_c=100; }
				$fwint2_attack_c = floor(($my_exploit*80)/$fwint2);
				if ($fwint2_attack_c>95) { $fwint2_attack_c=95; }
			}
		}
		
		//mf1
		if ($fwint1_as==3) {
			$difficult_p=$my_scanner/$mf1*100;
			if ($difficult_p>=100) { 
				$mf1_lvl=$mf1; 
				$mf1_anon_c = floor(($my_anon*100)/(($mf1+$siem)*1.25));
				if ($mf1_anon_c>100) { $mf1_anon_c=100; }
				$mf1_attack_c = floor(($my_exploit*60)/$mf1);
				if ($mf1_attack_c>95) { $mf1_attack_c=95; }
			}
		}
		
		//mf2
		if ($fwint2_as==3) {
			$difficult_p=$my_scanner/$mf2*100;
			if ($difficult_p>=100) { 
				$mf2_lvl=$mf2; 
				$mf2_anon_c = floor(($my_anon*100)/(($mf2+$siem)*1.25));
				if ($mf2_anon_c>100) { $mf2_anon_c=100; }
				$mf2_attack_c = floor(($my_exploit*60)/$mf2);
				if ($mf2_attack_c>95) { $mf2_attack_c=95; }
			}
		}
		
		//SIEM Disabled
		if ($siem_as==3) {
			$fwext_anon_c=100;
			$ips_anon_c=100;
			$siem_anon_c=100;
			$fwint1_anon_c=100;
			$fwint2_anon_c=100;
			$mf1_anon_c=100;
			$mf2_anon_c=100;
		}
		
		//User, Money, cpoints, mpoints
		$stmt = $db->prepare('SELECT datacenter.cpoints,user.username,user.money,user.crew_points FROM user JOIN datacenter ON user.crew=datacenter.crew_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"cpoints\": ".$row['cpoints'].",\n"
			."\"mpoints\": ".$row['crew_points'].",\n"
			."\"crew_name\": \"".$crew_name."\",\n"
			."\"fwext\": \"".$fwext_lvl."\",\n"
			."\"fwext_as\": ".$fwext_as.",\n"
			."\"fwext_anon_c\": \"".$fwext_anon_c."\",\n"
			."\"fwext_attack_c\": \"".$fwext_attack_c."\",\n"
			."\"ips\": \"".$ips_lvl."\",\n"
			."\"ips_as\": ".$ips_as.",\n"
			."\"ips_anon_c\": \"".$ips_anon_c."\",\n"
			."\"ips_attack_c\": \"".$ips_attack_c."\",\n"
			."\"siem\": \"".$siem_lvl."\",\n"
			."\"siem_as\": ".$siem_as.",\n"
			."\"siem_anon_c\": \"".$siem_anon_c."\",\n"
			."\"siem_attack_c\": \"".$siem_attack_c."\",\n"
			."\"fwint1\": \"".$fwint1_lvl."\",\n"
			."\"fwint1_as\": ".$fwint1_as.",\n"
			."\"fwint1_anon_c\": \"".$fwint1_anon_c."\",\n"
			."\"fwint1_attack_c\": \"".$fwint1_attack_c."\",\n"
			."\"fwint2\": \"".$fwint2_lvl."\",\n"
			."\"fwint2_as\": ".$fwint2_as.",\n"
			."\"fwint2_anon_c\": \"".$fwint2_anon_c."\",\n"
			."\"fwint2_attack_c\": \"".$fwint2_attack_c."\",\n"
			."\"mf1\": \"".$mf1_lvl."\",\n"
			."\"mf1_as\": ".$mf1_as.",\n"
			."\"mf1_anon_c\": \"".$mf1_anon_c."\",\n"
			."\"mf1_attack_c\": \"".$mf1_attack_c."\",\n"
			."\"mf2\": \"".$mf2_lvl."\",\n"
			."\"mf2_as\": ".$mf2_as.",\n"
			."\"mf2_anon_c\": \"".$mf2_anon_c."\",\n"
			."\"mf2_attack_c\": \"".$mf2_attack_c."\",\n"
			."}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>