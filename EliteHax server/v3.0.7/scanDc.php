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
		
		//Check unfinished scan from same user or same region from same crew
		$stmt = $db->prepare("SELECT id FROM `datacenter_scan` where (user_id=? and timestamp>NOW()) or (datacenter_id=? and timestamp>NOW() and crew_id=(SELECT crew FROM user WHERE id=?))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { exit(); }
		
		//My DC Power
		$stmt = $db->prepare("SELECT datacenter_id,(fwext+ips+siem+fwint1+fwint2+mf1+mf2+scanner+exploit+anon) as count FROM `datacenter_upgrades` WHERE datacenter_id=(SELECT id FROM datacenter WHERE crew_id=(SELECT crew FROM user WHERE id=?))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_dc_power = $row['count'];
		}
		
		//Target DC Power
		$stmt = $db->prepare("SELECT datacenter_id,(fwext+ips+siem+fwint1+fwint2+mf1+mf2+scanner+exploit+anon) as count FROM `datacenter_upgrades` WHERE datacenter_id=?");
		$stmt->bindValue(1, $dc, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$dc_power = $row['count'];
		}
		
		//Target Crew Wallet
		$stmt = $db->prepare("SELECT crew.wallet FROM crew JOIN datacenter ON datacenter.crew_id=crew.id WHERE datacenter.id=?");
		$stmt->bindValue(1, $dc, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$target_wallet = $row['wallet'];
		}
		
		$difficult_p=$dc_power/$my_dc_power*100;
		if ($difficult_p<=50) { $difficult=1; }
		elseif ($difficult_p<=75) { $difficult=2; }
		elseif ($difficult_p<=125) { $difficult=3; }
		elseif ($difficult_p<=175) { $difficult=4; }
		else { $difficult=5; }
		
		$stmt = $db->prepare("INSERT INTO datacenter_scan (crew_id, datacenter_id, user_id, difficult, region, wallet, timestamp) VALUES ((SELECT crew FROM user WHERE id=?),?,?,?,(SELECT region FROM datacenter WHERE id=?),?,NOW() + INTERVAL 3600 SECOND)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, $difficult, PDO::PARAM_INT);
		$stmt->bindValue(5, $dc, PDO::PARAM_INT);
		$stmt->bindValue(6, $target_wallet, PDO::PARAM_INT);
		$stmt->execute();	

		$resp = "{\n\"status\": \"OK\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>