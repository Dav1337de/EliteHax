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
		$stmt = $db->prepare("SELECT * FROM msg_contacts WHERE contact=(SELECT uuid FROM user WHERE username=?) and uuid=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) { 
			$resp = "{\n\"status\": \"AA\"\n}";
			//echo $resp;
			exit(base64_encode($resp));		
		}
		//Check Existing Requests
		$stmt = $db->prepare("SELECT * FROM msg_request WHERE dst=(SELECT uuid FROM user WHERE username=?) and src=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) { 
			$resp = "{\n\"status\": \"AS\"\n}";
			//echo $resp;
			exit(base64_encode($resp));		
		}
		else {
			$stmt = $db->prepare("INSERT INTO msg_request (src,dst,timestamp) VALUES ((SELECT uuid FROM user WHERE id=?),(SELECT uuid FROM user WHERE username=?),NOW())"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $username, PDO::PARAM_STR);
			$stmt->execute();
			$resp = "{\"status\": \"OK\"\n}";
			//echo $resp;
			echo base64_encode($resp);
		}

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>