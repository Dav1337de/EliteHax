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
		//Newbies,Hackers or Crew Mentor
		if (($my_role > 3) or ($member_role < 3)) { exit("An Error occured!"); }
		//Same Role or less
		if ($my_role >= $member_role) { exit("An Error occured!"); }

		if ($member_role == 3) { $role_name = "The Elite"; }
		elseif ($member_role == 4) { $role_name = "Expert"; }
		elseif ($member_role == 5) { $role_name = "Hacker"; }
		
		$stmt = $db->prepare("UPDATE user SET crew_role=crew_role-1 WHERE id=?"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,field3,timestamp) VALUES ('action','promote',?,?,?,?,NOW())");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $member_name, PDO::PARAM_STR);
		$stmt->bindValue(3, $my_name, PDO::PARAM_STR);
		$stmt->bindValue(4, $role_name, PDO::PARAM_STR);
		$stmt->execute();
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>