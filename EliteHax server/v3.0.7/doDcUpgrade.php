<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['type']))
		exit("An Error occured!");
	$type = $_POST['type'];
	$whitelist = Array( 'fwext', 'ips', 'siem', 'fwint1', 'fwint2', 'mf1', 'mf2', 'scanner', 'exploit', 'relocate', 'anon', 'mf1_testprod', 'mf2_testprod' );
	if( !in_array( $type, $whitelist ) )
		exit("An Error occured!");
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT datacenter.cpoints,user.crew,user.crew_points,user.crew_role,user.crew FROM user JOIN datacenter ON user.crew=datacenter.crew_id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$crew = $row['crew'];
			$my_role = $row['crew_role'];
			$my_cpoints = $row['crew_points'];
			$crew_id = $row['crew'];
			$cpoints = $row['cpoints'];
		}
		
		if ($my_role>4) {
			exit(base64_encode("{\n\"status\": \"NA\"\n}"));
		}
		
		if ($my_cpoints>=2) {
			exit(base64_encode("{\n\"status\": \"MAX\"\n}"));
		}			
		
		if ($cpoints>=50) {
			exit(base64_encode("{\n\"status\": \"CMAX\"\n}"));
		}
		
		$new_prod=0;
		if ($type=="relocate") {
			$stmt = $db->prepare("SELECT datacenter_upgrades.relocate FROM datacenter_upgrades WHERE datacenter_id = (SELECT id FROM datacenter WHERE crew_id=?)"); 
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$relocate=$row['relocate'];
			}
			if ($relocate==99) {
				$stmt = $db->prepare("UPDATE datacenter_upgrades SET relocate=0 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("UPDATE datacenter SET relocation=relocation+1 where crew_id=?");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();
			}
			else {
				$stmt = $db->prepare("UPDATE datacenter_upgrades SET {$type}={$type}+1 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();
			}
		} 
		elseif ($type=="mf1_testprod") {
			$stmt = $db->prepare("SELECT datacenter_upgrades.mf1_testprod,datacenter_upgrades.mf_prod FROM datacenter_upgrades WHERE datacenter_id = (SELECT id FROM datacenter WHERE crew_id=?)"); 
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$mf_prod=$row['mf_prod'];
				$mf1_testprod=$row['mf1_testprod'];
			}
			if ($mf_prod==1) {
				exit(base64_encode("{\n\"status\": \"REFRESH\"\n}"));
			}
			elseif ($mf1_testprod < 49) {
				$stmt = $db->prepare("UPDATE datacenter_upgrades SET mf1_testprod=mf1_testprod+1 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();
			}
			else {
				$stmt = $db->prepare("UPDATE datacenter_upgrades SET mf1_testprod=0,mf_prod=1 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();	
				$new_prod=1;
			}
		}
		elseif ($type=="mf2_testprod") {
			$stmt = $db->prepare("SELECT datacenter_upgrades.mf2_testprod,datacenter_upgrades.mf_prod FROM datacenter_upgrades WHERE datacenter_id = (SELECT id FROM datacenter WHERE crew_id=?)"); 
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$mf_prod=$row['mf_prod'];
				$mf2_testprod=$row['mf2_testprod'];
			}
			if ($mf_prod==2) {
				exit(base64_encode("{\n\"status\": \"REFRESH\"\n}"));
			}
			elseif ($mf2_testprod < 49) {
				$stmt = $db->prepare("UPDATE datacenter_upgrades SET mf2_testprod=mf2_testprod+1 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();
			}
			else {
				$stmt = $db->prepare("UPDATE datacenter_upgrades SET mf2_testprod=0,mf_prod=2 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
				$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
				$stmt->execute();	
				$new_prod=2;
			}
		}
		else {
			$stmt = $db->prepare("UPDATE datacenter_upgrades SET {$type}={$type}+1 where datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)");
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		
		$stmt = $db->prepare("UPDATE user SET crew_points=crew_points+1 WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE datacenter SET cpoints=cpoints+1 WHERE crew_id=?");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Log
		$stmt = $db->prepare("INSERT INTO crew_wars_logs (crew,user_id,type,target,timestamp) VALUES (?,?,?,?,NOW())");
		$stmt->bindValue(1, $crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, "upgrade", PDO::PARAM_STR);
		$stmt->bindValue(4, $type, PDO::PARAM_STR);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\",\n\"new_prod\": ".$new_prod."\n}";
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>
