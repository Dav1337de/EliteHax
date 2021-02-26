<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$db->beginTransaction();
		$stmt = $db->prepare("SELECT user.id,user.username,user.crew_role,crew.name,user.crew FROM user JOIN crew ON user.crew=crew.id WHERE user.crew = (SELECT crew FROM user WHERE id=?) and user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
			$my_role = $row['crew_role'];
			$my_name = $row['username'];
		}
		//Check Role
		if ($my_role > 1) { exit("An Error occured!"); }
		
		//Remove Users
		$stmt = $db->prepare("UPDATE user SET crew=0,crew_role=0,crew_contribution=0 WHERE crew=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();		
		
		//Delete Crew Requests
		$stmt = $db->prepare("DELETE FROM crew_requests WHERE crew_id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();	
		
		//Delete Crew Chat
		$stmt = $db->prepare("DELETE FROM crew_chat WHERE crew_id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();	

		//Delete Crew Chat
		$stmt = $db->prepare("DELETE FROM crew_invitation WHERE crew_id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();		
		
		//Delete Datacenter Upgrades
		$stmt = $db->prepare("DELETE FROM datacenter_upgrades WHERE datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Datacenter Scan
		$stmt = $db->prepare("DELETE FROM datacenter_scan WHERE crew_id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Region Scan
		$stmt = $db->prepare("DELETE FROM region_scan WHERE crew_id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Datacenter Attack
		$stmt = $db->prepare("DELETE FROM datacenter_attacks WHERE attacking_crew=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Datacenter
		$stmt = $db->prepare("DELETE FROM datacenter WHERE crew_id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Crew
		$stmt = $db->prepare("DELETE FROM crew WHERE id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();		
		$db->commit();
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>