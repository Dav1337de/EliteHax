<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['crew_id'])) { exit(); }
	$crew_id=$_POST['crew_id'];
	try {
		$id = getIdFromToken($db);
		
		//Check Invitation
		$stmt = $db->prepare("SELECT user2.username,user1.username as inviter_username FROM crew_invitation JOIN user as user1 ON crew_invitation.inviter_id=user1.id JOIN user as user2 ON crew_invitation.user_id=user2.id WHERE user_id=? and crew_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			exit(base64_encode("{\n\"status\": \"NE\"\n}"));
		}
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$inviter_username = $row['inviter_username'];
			$new_member = $row['username'];
		}
		
		//Check Members
		$stmt = $db->prepare("SELECT crew.slot,(select count(id) as members FROM user WHERE user.crew = ? GROUP BY crew) as members FROM crew WHERE crew.id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$slot = $row['slot'];
			$members = $row['members'];
		}
		//Check if full
		if ($members >= $slot) { exit(base64_encode("{\n\"status\": \"FULL\"\n}")); }
		
		//Add to Crew
		$stmt = $db->prepare("UPDATE user SET crew=?,crew_role=5 WHERE id=?"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();

		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,timestamp) VALUES ('action','accept_invite',?,?,?,NOW())");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $new_member, PDO::PARAM_STR);
		$stmt->bindValue(3, $inviter_username, PDO::PARAM_STR);
		$stmt->execute();
		
		//Delete Requests
		$stmt = $db->prepare("DELETE FROM crew_requests WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Delete Invitations
		$stmt = $db->prepare("DELETE FROM crew_invitation WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>