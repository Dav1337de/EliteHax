<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("SELECT notepad FROM notepad WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
		$resp = "{\n\"notepad\": \"".$row['notepad']
		."\",\n}";
		echo base64_encode($resp);		
		//echo $resp;
		}

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>