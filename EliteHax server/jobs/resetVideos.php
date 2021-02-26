<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		
		//$stmt = $db->prepare("UPDATE items SET videos=0 WHERE videos != 0");		
		//$stmt->execute();
		
		sleep(3);
		
		$stmt = $db->prepare("UPDATE user INNER JOIN upgrades ON upgrades.id=user.id SET user.new_cryptocoins=user.new_cryptocoins+upgrades.cryptominer where user.new_cryptocoins<(upgrades.cryptominer*48)");
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE user SET crew_points=0 WHERE crew_points != 0");		
		$stmt->execute();

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>