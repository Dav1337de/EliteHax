<?php
	include 'db.php';
	include 'validate.php';

	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins+new_cryptocoins, new_cryptocoins=0 WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\",\n}";
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>
