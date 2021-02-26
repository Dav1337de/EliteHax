<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		//Validate Crew Wallet Percentage
		if (!isset($_POST['new_mentor']))
			exit("An Error occured!");
			
		$stmt = $db->prepare("SELECT user.id,user.username,user.crew_role,crew.name,user.crew FROM user JOIN crew ON user.crew=crew.id WHERE user.crew = (SELECT crew FROM user WHERE id=?) and user.id=? or user.uuid=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $_POST['new_mentor'], PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 2) {
			exit("An Error occured!");
		}
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['id'] == $id) {
				$crew_id = $row['crew'];
				$my_role = $row['crew_role'];
				$my_name = $row['username'];
			}
			else {
				$member_role = $row['crew_role'];
				$member_name = $row['username'];
			}
		}
		//Check Role
		if ($my_role > 1) { exit("An Error occured!"); }
		if ($member_role != 2) { exit("An Error occured!"); }
		
		$stmt = $db->prepare("UPDATE user SET crew_role=2 WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("UPDATE user SET crew_role=1 WHERE uuid=?"); 
		$stmt->bindValue(1, $_POST['new_mentor'], PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,timestamp) VALUES ('action','mentor',?,?,?,NOW())");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $member_name, PDO::PARAM_STR);
		$stmt->bindValue(3, $my_name, PDO::PARAM_STR);
		$stmt->execute();
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>