<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['username'])) { exit(""); }
	$username = $_POST['username'];
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("DELETE FROM msg_contacts WHERE uuid=(SELECT uuid FROM user WHERE username=?) and contact=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("DELETE FROM msg_contacts WHERE contact=(SELECT uuid FROM user WHERE username=?) and uuid=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("DELETE FROM private_chat WHERE ((uuid1=(SELECT uuid FROM user WHERE username=?) and uuid2=(SELECT uuid FROM user WHERE id=?)) OR (uuid1=(SELECT uuid FROM user WHERE id=?) and uuid2=(SELECT uuid FROM user WHERE username=?)))"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, $username, PDO::PARAM_STR);
		$stmt->execute();
		
		$resp = "{\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>