<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['ip']))
		exit("");
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("DELETE FROM target_list WHERE user_id=? and ip=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, sprintf('%u', ip2long($_POST['ip'])), PDO::PARAM_STR);
		$stmt->execute();
		$resp = "{\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>