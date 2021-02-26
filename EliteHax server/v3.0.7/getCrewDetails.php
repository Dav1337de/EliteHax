<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT crew.* FROM crew WHERE id=?"); 
		$stmt->bindValue(1, $_POST['crew_id'], PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = "{\"name\": \"".$row['name']."\",\n"
			."\"id\": \"".$row['id']."\",\n"
			."\"desc\": \"".$row['description']."\",\n"
			."\"tournament_best\": \"".$row['tournament_best']."\",\n"
			."\"tournament_won\": \"".$row['tournament_won']."\",\n"
			."\"tag\": \"".$row['tag']."\",\n";
		}
		//Crew Rank
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT crew, members, score, reputation, rank FROM (SELECT crew, members, score, reputation, @curRank := @curRank + 1 AS rank FROM (SELECT crew, COUNT(id) as members, SUM(score) as score, SUM(reputation) as reputation FROM user WHERE crew <> 0 GROUP BY crew ORDER BY sum(reputation+score) DESC LIMIT 100000) as t) as t2 WHERE crew=?');
		$stmt->bindValue(1, $_POST['crew_id'], PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"crank\": ".$row['rank'].",\n"
			."\"members\": ".$row['members'].",\n"
			."\"cscore\": ".$row['score'].",\n"
			."\"creputation\": ".$row['reputation']."}\n";
		}			
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>