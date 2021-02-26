<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['rat_id'])) { exit(); }
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("DELETE FROM rat WHERE attacker_id=? and defense_id=(SELECT id FROM user WHERE uuid=?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['rat_id'], PDO::PARAM_STR);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>