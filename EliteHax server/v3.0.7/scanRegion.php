<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['region']))
		exit("An Error occured!");
	$region = $_POST['region'];
	if (!is_numeric($region))
		exit("An Error occured!");
	if (($region<1) or ($region>18))
		exit("An Error occured!");

	try {
		$id = getIdFromToken($db);
		
		//Check unfinished scan from same user or same region from same crew
		$stmt = $db->prepare("SELECT id FROM `region_scan` where (user_id=? and timestamp>NOW()) or (region=? and timestamp>NOW() and crew_id=(SELECT crew FROM user WHERE id=?))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $region, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { exit(); }
		
		$stmt = $db->prepare("INSERT INTO region_scan (crew_id, region, user_id, timestamp) VALUES ((SELECT crew FROM user WHERE id=?),?,?,NOW() + INTERVAL 3600 SECOND)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $region, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();	

		$resp = "{\n\"status\": \"OK\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>