<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['username']))
		exit("");
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("DELETE FROM msg_request WHERE src=(SELECT uuid FROM user WHERE username=?) and dst=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $_POST['username'], PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>