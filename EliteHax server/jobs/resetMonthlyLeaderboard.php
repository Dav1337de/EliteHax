<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		//Player Tables
		sleep(15);
		$stmt = $db->prepare("UPDATE user SET score_monthly=score,rep_monthly=reputation,rep2_monthly=missions_rep WHERE score>0 or missions_rep>0");		
		$stmt->execute();

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>