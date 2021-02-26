<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$my_role = 1;
		$stmt = $db->prepare("SELECT username,crew_role,crew FROM user WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_role = $row['crew_role'];
			$my_name = $row['username'];
			$crew_id = $row['crew'];
		}
		//Crew Mentor
		if ($my_role == 1) { exit("An Error occured!"); }

		$stmt = $db->prepare("UPDATE user SET crew=0,crew_role=0,crew_contribution=0 WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,timestamp) VALUES ('action','leave',?,?,NOW())");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $my_name, PDO::PARAM_STR);
		$stmt->execute();
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>