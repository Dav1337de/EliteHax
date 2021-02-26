<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		if ($id == $_POST['member_id']) { exit("An Error occured!"); }
		
		$stmt = $db->prepare("SELECT user.id,user.username,user.crew_role,crew.name,user.crew FROM user JOIN crew ON user.crew=crew.id WHERE user.crew = (SELECT crew FROM user WHERE id=?) and user.id=? or user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $_POST['member_id'], PDO::PARAM_INT);
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
			elseif ($row['id'] == $_POST['member_id']) {
				$member_role = $row['crew_role'];
				$member_name = $row['username'];
			}
		}
		//Newbies,Hackers,Experts or Crew Mentor
		if (($my_role > 2) or ($member_role == 1)) { exit("An Error occured!"); }
		//Same Role or less
		if ($my_role >= $member_role) { exit("An Error occured!"); }
		
		$stmt = $db->prepare("UPDATE user SET crew=0,crew_role=0,crew_contribution=0 WHERE id=?"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//Add Message to chat
		$message = $member_name." has been kicked by ".$my_name;
		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,timestamp) VALUES ('action','kick',?,?,?,NOW())");
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