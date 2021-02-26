<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		//Player Tables
		$stmt = $db->prepare("DROP TABLE IF EXISTS tournament_score_start");		
		$stmt->execute();
		$stmt = $db->prepare("DROP TABLE IF EXISTS tournament_score_finish");		
		$stmt->execute();
		$stmt = $db->prepare("CREATE TABLE tournament_score_start AS (SELECT id,username,score,crew FROM user)");		
		$stmt->execute();
		
		//Crew Tables
		$stmt = $db->prepare("DROP TABLE IF EXISTS tournament_score_start_crew");		
		$stmt->execute();
		$stmt = $db->prepare("DROP TABLE IF EXISTS tournament_score_finish_crew");		
		$stmt->execute();
		$stmt = $db->prepare("CREATE TABLE tournament_score_start_crew AS (SELECT crew as crew, crew.tag as tag, crew.name as name, SUM(score) as score FROM user JOIN crew ON user.crew=crew.id WHERE user.crew <> 0 GROUP BY user.crew ORDER BY sum(reputation+score) DESC)");		
		$stmt->execute();
		
		//GitHub Note: Send Push Notification for tournament start
		$response = sendMessage("9738a59c-3468-4b5d-8acc-0c533bb286d3");

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>