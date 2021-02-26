<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['username']))
		exit("");
	$username=$_POST['username'];
	try {
		$id = getIdFromToken($db);
		//Check Existing Username
		$stmt = $db->prepare("SELECT uuid FROM user WHERE username=?"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { 
			$resp = "{\n\"status\": \"NA\"\n}";
			//echo $resp;
			exit(base64_encode($resp));		
		}		
		//Check Existing Contacts
		$stmt = $db->prepare("SELECT crew FROM user WHERE username=? and crew<>0"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() != 0) { 
			$resp = "{\n\"status\": \"AC\"\n}";
			//echo $resp;
			exit(base64_encode($resp));		
		}
		//Check Existing Requests
		$stmt = $db->prepare("SELECT * FROM crew_invitation WHERE user_id=(SELECT id FROM user WHERE username=?) and crew_id=(SELECT crew FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) { 
			$resp = "{\n\"status\": \"AS\"\n}";
			//echo $resp;
			exit(base64_encode($resp));		
		}
		else {
			$stmt = $db->prepare("SELECT username,crew FROM user WHERE id=?"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$my_username = $row['username'];
				$crew_id = $row['crew'];
			}
			
			$stmt = $db->prepare("INSERT INTO crew_invitation (user_id,crew_id,inviter_id,timestamp) VALUES ((SELECT id FROM user WHERE username=?),?,?,NOW())"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();

			//Add Message to logs
			$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,timestamp) VALUES ('action','invitation',?,?,?,NOW())");
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $username, PDO::PARAM_STR);
			$stmt->bindValue(3, $my_username, PDO::PARAM_STR);
			$stmt->execute();
			
			$resp = "{\"status\": \"OK\"\n}";
			//echo $resp;
			echo base64_encode($resp);
		}

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>