<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//Check Crew Requests
		$stmt = $db->prepare("SELECT * FROM crew_requests WHERE user_id=? and crew_id=(SELECT crew FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			exit(base64_encode("{\n\"status\": \"NE\"\n}"));
		}
		
		$stmt = $db->prepare("SELECT user.username,user.crew_role,user.crew, crew.name, crew.slot,(select count(id) as members FROM user WHERE user.crew = (SELECT crew FROM user WHERE id=?) GROUP BY crew) as members FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$crew_name = $row['name'];
			$my_name = $row['username'];
			$crew_id = $row['crew'];
			$my_role = $row['crew_role'];
			$slot = $row['slot'];
			$members = $row['members'];
		}
		if ($my_role > 3) { exit("An Error occured!"); }
		
		//Check if full
		if ($members >= $slot) { exit(base64_encode("{\n\"status\": \"FULL\"\n}")); }
		
		//Add to Crew
		$stmt = $db->prepare("UPDATE user SET crew=?,crew_role=5 WHERE id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		
		//Get Name
		$stmt = $db->prepare("SELECT user.username FROM user WHERE id=?"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$new_member = $row['username'];
		}
		
		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,timestamp) VALUES ('action','join',?,?,?,NOW())");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $new_member, PDO::PARAM_STR);
		$stmt->bindValue(3, $my_name, PDO::PARAM_STR);
		$stmt->execute();
		
		//Delete Requests
		$stmt = $db->prepare("DELETE FROM crew_requests WHERE user_id=?"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Invitations
		$stmt = $db->prepare("DELETE FROM crew_invitation WHERE user_id=?"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>