<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT tournaments_new.type FROM `tournaments_new` WHERE CURTIME()>time_start ORDER BY time_start desc LIMIT 3");
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($i==1) {
				$current = $row['type'];
				$i++;
			}
			elseif ($i==2) {
				$previous_type = $row['type'];
				$i++;
			}
			elseif ($i==3) {
				$previous_type2 = $row['type'];
				$i++;
			}
		}
		if ($stmt->rowCount() == 1) { 
			$previous_type=2;
		}
		if ($previous_type==0) { $previous_type=$previous_type2; }
		
		if ($current==2) {
			//TOP100
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT username,score,tag, @curRank := @curRank + 1 AS rank FROM (SELECT user.id,user.username,(user.score-tournament_score_start.score) as score, crew.tag FROM user JOIN tournament_score_start ON user.id=tournament_score_start.id LEFT JOIN crew ON user.crew=crew.id WHERE (user.score-tournament_score_start.score)>0 ORDER BY (user.score-tournament_score_start.score) DESC,user.id ASC LIMIT 100) as t');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['username']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"score\": ".$row['score'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";
			
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT username, money, rank, score FROM (SELECT id,username,money,score,tag, @curRank := @curRank + 1 AS rank FROM (SELECT user.id,user.username,(user.score-tournament_score_start.score) as score, user.money, crew.tag FROM user JOIN tournament_score_start ON user.id=tournament_score_start.id LEFT JOIN crew ON user.crew=crew.id WHERE (user.score-tournament_score_start.score)>0 ORDER BY (user.score-tournament_score_start.score) DESC,user.id ASC LIMIT 100000000) as t) as t2 WHERE t2.id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['score'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT username, money FROM user WHERE id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": 0,\n";
				}				
			}
			$db->commit();		
		} 
		elseif (($current==1) or (($current==0) and ($previous_type==1))) {
			//TOP100
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t.*,@curRank := @curRank + 1 AS rank FROM (SELECT tournament_hack.*,crew.tag FROM `tournament_hack` LEFT JOIN crew ON tournament_hack.crew=crew.id WHERE hack_count>0 and money_hack>0 order by money_hack DESC, hack_count ASC LIMIT 100) as t');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['username']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"score\": ".$row['money_hack'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";		
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT username, money, rank, money_hack, hack_count FROM (SELECT id,username,money,money_hack,hack_count,@curRank := @curRank + 1 AS rank FROM (SELECT tournament_hack.*,user.money FROM `tournament_hack` JOIN user ON tournament_hack.id=user.id WHERE hack_count>0 and money_hack>0 order by money_hack DESC, hack_count ASC LIMIT 100000000) as t) as t2 WHERE t2.id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"hack_left\": ".(100-$row['hack_count']).",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['money_hack'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT user.username, user.money, hack_count FROM user JOIN tournament_hack ON user.id=tournament_hack.id WHERE user.id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"hack_left\": ".(100-$row['hack_count']).",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": 0,\n";
				}				
			}
			$db->commit();	
		}
		elseif (($current==0) and ($previous_type==2)) {
			//TOP100
			$db->beginTransaction();
			$stmt = $db->prepare('SELECT * FROM tournament_score_finish');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['username']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"score\": ".$row['score'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";
			
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t.username, user.money, t.rank, t.score FROM (SELECT * FROM tournament_score_finish) as t JOIN user ON t.id=user.id WHERE t.id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['score'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT username, money FROM user WHERE id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": 0,\n";
				}				
			}
			$db->commit();			
		}
		elseif (($current==3) or (($current==0) and ($previous_type==3))) {
			//TOP100
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t.*,@curRank := @curRank + 1 AS rank FROM (SELECT tournament_hackdefend.*,crew.tag FROM `tournament_hackdefend` LEFT JOIN crew ON tournament_hackdefend.crew=crew.id WHERE hack_count>0 order by money_hack DESC, hack_count ASC LIMIT 100) as t');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['username']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"score\": ".$row['money_hack'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";		
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT username, money, rank, money_hack, hack_count FROM (SELECT id,username,money,money_hack,hack_count,@curRank := @curRank + 1 AS rank FROM (SELECT tournament_hackdefend.*,user.money FROM `tournament_hackdefend` JOIN user ON tournament_hackdefend.id=user.id WHERE hack_count>0 order by money_hack DESC, hack_count ASC LIMIT 100000000) as t) as t2 WHERE t2.id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"hack_left\": ".(100-$row['hack_count']).",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['money_hack'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT user.username, user.money, hack_count FROM user JOIN tournament_hackdefend ON user.id=tournament_hackdefend.id WHERE user.id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"hack_left\": ".(100-$row['hack_count']).",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": 0,\n";
				}				
			}
			$db->commit();	
		}
		
		$resp = $resp."\"active\": \"".$current."\",\n";
		if ($current==0) { $current=$previous_type; }
		$resp = $resp."\"type\": \"".$current."\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>