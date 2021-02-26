<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$notepad = substr(json_encode($_POST['notepad']), 1, -1);
		
		$stmt = $db->prepare("UPDATE notepad SET notepad=? where id=?");
		$stmt->bindValue(1, $notepad, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\",\n}";
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>