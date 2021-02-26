<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['username']))
		exit("");
	$username=$_POST['username'];
	try {
		$id = getIdFromToken($db);
		//Check Existing Requests
		$stmt = $db->prepare("SELECT * FROM msg_request WHERE src=(SELECT uuid FROM user WHERE username=?) and dst=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) { 
			$stmt = $db->prepare("INSERT INTO msg_contacts (uuid,contact,timestamp) VALUES ((SELECT uuid FROM user WHERE id=?),(SELECT uuid FROM user WHERE username=?),NOW())"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $username, PDO::PARAM_STR);
			$stmt->execute();
			
			$stmt = $db->prepare("INSERT INTO msg_contacts (uuid,contact,timestamp) VALUES ((SELECT uuid FROM user WHERE username=?),(SELECT uuid FROM user WHERE id=?),NOW())"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
		
			$stmt = $db->prepare("DELETE FROM msg_request WHERE src=(SELECT uuid FROM user WHERE username=?) and dst=(SELECT uuid FROM user WHERE id=?)"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("DELETE FROM msg_request WHERE dst=(SELECT uuid FROM user WHERE username=?) and src=(SELECT uuid FROM user WHERE id=?)"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$resp = "{\n\"status\": \"OK\"\n}";
			//echo $resp;
			echo base64_encode($resp);		
		}
		else {
			$resp = "{\"status\": \"KO\"\n}";
			//echo $resp;
			echo base64_encode($resp);
		}

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>