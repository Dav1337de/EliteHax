<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT id,uuid FROM user WHERE user.ip=?");
		$stmt->bindValue(1, sprintf('%u', ip2long($_POST['target'])), PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			exit(base64_encode("{\n\"status\": \"KO\",\n\"ip\": \"No\"}"));
		}
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['id'] == $id) { exit(base64_encode("{\n\"status\": \"KO\",\n\"ip\": \"No\"}")); }
			$uuid = $row['uuid'];
		}
		$resp = "{\n\"status\": \"OK\",\n\"id\": \"".$uuid."\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>