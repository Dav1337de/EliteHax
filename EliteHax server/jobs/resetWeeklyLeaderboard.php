<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		//Player Tables
		$stmt = $db->prepare("UPDATE user SET score_weekly=score,rep_weekly=reputation,rep2_weekly=missions_rep WHERE score>0 or missions_rep>0");		
		$stmt->execute();

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>