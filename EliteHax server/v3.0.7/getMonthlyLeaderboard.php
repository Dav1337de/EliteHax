<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//TOP100
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT user.id, username, (score-score_monthly) as score, (reputation-rep_monthly) as reputation, crew.tag, @curRank := @curRank + 1 AS rank FROM user LEFT JOIN crew ON user.crew=crew.id ORDER BY (score-score_monthly) DESC, id LIMIT 100');
		$stmt->execute();
		$db->commit();
		$resp = "{\"ranks\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if (($row['score']+$row['reputation'])>0) {
				$resp = $resp."{\"user\": \"".$row['username']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"score\": ".$row['score'].",\n"
				."\"rank\": ".$row['rank'].",\n"
				."\"reputation\": ".$row['reputation']."\n},";
			}
		}
		$resp = $resp."],";
		
		//Player Rank
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT username, money, rank, score, reputation FROM (SELECT id, username, money, (score-score_monthly) as score, (reputation-rep_monthly) as reputation, @curRank := @curRank + 1 AS rank FROM user ORDER BY (score-score_monthly) DESC,crew) as t WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();		
		$db->commit();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$resp = $resp."\"prank\": ".$row['rank'].",\n"
				."\"musername\": \"".$row['username']."\",\n"
				."\"mmoney\": ".$row['money'].",\n"
				."\"mscore\": ".$row['score'].",\n"
				."\"mreputation\": ".$row['reputation']."}\n";
		}			
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>