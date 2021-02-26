<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//TOP100
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT crew, tag, name, score, reputation, @curRank := @curRank + 1 AS rank FROM (SELECT crew as crew, crew.tag as tag, crew.name as name, SUM(score) as score, SUM(reputation) as reputation FROM user JOIN crew ON user.crew=crew.id WHERE user.crew <> 0 GROUP BY user.crew ORDER BY sum(reputation+score) DESC LIMIT 100) as t');
		$stmt->execute();
		$db->commit();
		$resp = "{\"ranks\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"user\": \"".$row['name']."\",\n"
			."\"id\": ".$row['crew'].",\n"
			."\"crew\": \"".$row['tag']."\",\n"
			."\"score\": ".$row['score'].",\n"
			."\"rank\": ".$row['rank'].",\n"
			."\"reputation\": ".$row['reputation']."\n},";
		}
		$resp = $resp."],";
		
		//Player Rank
		$prank = 0;
		$mscore = 0;
		$mreputation = 0;
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT crew, members, score, reputation, rank FROM (SELECT crew, members, score, reputation, @curRank := @curRank + 1 AS rank FROM (SELECT crew, COUNT(id) as members, SUM(score) as score, SUM(reputation) as reputation FROM user WHERE crew <> 0 GROUP BY crew ORDER BY sum(reputation+score) DESC LIMIT 10000) as t) as t2 WHERE crew=(SELECT crew FROM user WHERE id=?)');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	
		$db->commit();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$prank = $row['rank'];
			$mscore = $row['score'];
			$mreputation = $row['reputation'];
		}			
		$resp = $resp."\"prank\": ".$prank.",\n"
		."\"mscore\": ".$mscore.",\n"
		."\"mreputation\": ".$mreputation."}\n";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>