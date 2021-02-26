<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		if (!isset($_POST['message'])) { exit(); }
		if (!isset($_POST['dest'])) { exit(""); }
		//if (strlen($_POST['message'] < 1)) { exit(); }
		
		$username=$_POST['dest'];
		$message=urldecode($_POST['message']);
   		$escapers = array("\\", "/", "\"", "\n", "\r", "\t", "\x08", "\x0c");
    	$replacements = array("\\\\", "\\/", "\\\"", "\\n", "\\r", "\\t", "\\f", "\\b");
		$message = str_replace($escapers, $replacements, $message);
		$message=ltrim($message, '"');
		
		if ($message != "") {
		
			$stmt = $db->prepare("SELECT * FROM msg_contacts WHERE contact=(SELECT uuid FROM user WHERE username=?) and uuid=(SELECT uuid FROM user WHERE id=?)"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			if ($stmt->rowCount() == 0) { 
				exit("");		
			}
			$stmt = $db->prepare("INSERT INTO private_chat (uuid1,uuid2,message,timestamp) VALUES ((SELECT uuid FROM user WHERE id=?),(SELECT uuid FROM user WHERE username=?),?,NOW())"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $username, PDO::PARAM_INT);
			$stmt->bindValue(3, $message, PDO::PARAM_STR);
			$stmt->execute();			
			
			$stmt = $db->prepare("DELETE FROM private_chat WHERE id NOT IN ( SELECT t.id FROM (SELECT id FROM private_chat WHERE ((uuid1=(SELECT uuid FROM user WHERE username=?) and uuid2=(SELECT uuid FROM user WHERE id=?)) OR (uuid1=(SELECT uuid FROM user WHERE id=?) and uuid2=(SELECT uuid FROM user WHERE username=?))) ORDER BY id DESC LIMIT 50 ) as t) and ((uuid1=(SELECT uuid FROM user WHERE username=?) and uuid2=(SELECT uuid FROM user WHERE id=?)) OR (uuid1=(SELECT uuid FROM user WHERE id=?) and uuid2=(SELECT uuid FROM user WHERE username=?)))"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->bindValue(4, $username, PDO::PARAM_STR);
			$stmt->bindValue(5, $username, PDO::PARAM_STR);
			$stmt->bindValue(6, $id, PDO::PARAM_INT);
			$stmt->bindValue(7, $id, PDO::PARAM_INT);
			$stmt->bindValue(8, $username, PDO::PARAM_STR);
			$stmt->execute();
		}
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>