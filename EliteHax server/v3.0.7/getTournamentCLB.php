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
			$stmt = $db->prepare('SELECT t2.*,@curRank := @curRank + 1 AS rank FROM (SELECT t.*,crew.name,crew.tag FROM (SELECT user.crew as crew,(SUM(user.score)-SUM(tournament_score_start.score)) as diff FROM user JOIN tournament_score_start ON tournament_score_start.id = user.id WHERE user.crew <> 0 GROUP BY crew HAVING ((SUM(user.score)-SUM(tournament_score_start.score))>0) and count(user.crew)>2 ORDER BY (SUM(user.score)-SUM(tournament_score_start.score)) DESC LIMIT 100) as t JOIN crew on t.crew=crew.id ORDER BY diff DESC LIMIT 100) as t2');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['name']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"id\": \"".$row['crew']."\",\n"
				."\"score\": ".$row['diff'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";
			
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t3.*,(SELECT user.username FROM user WHERE id=?) as username,(SELECT user.money FROM user WHERE id=?) as money FROM (SELECT t2.*,@curRank := @curRank + 1 AS rank FROM (SELECT t.*,crew.name,crew.tag FROM (SELECT user.crew as crew,(SUM(user.score)-SUM(tournament_score_start.score)) as diff FROM user JOIN tournament_score_start ON tournament_score_start.id = user.id WHERE user.crew <> 0 GROUP BY crew HAVING ((SUM(user.score)-SUM(tournament_score_start.score))>0) and count(user.crew)>2 ORDER BY (SUM(user.score)-SUM(tournament_score_start.score)) DESC LIMIT 100000000) as t JOIN crew on t.crew=crew.id ORDER BY diff DESC LIMIT 1000000000) as t2) as t3 WHERE t3.crew=(SELECT crew FROM user WHERE id=?)');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['diff'].",\n";
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
			$stmt = $db->prepare('SELECT t2.*,@curRank := @curRank + 1 AS rank FROM (SELECT t.* FROM (SELECT tournament_hack.crew,SUM(money_hack) as total,crew.name,crew.tag FROM `tournament_hack` JOIN crew ON tournament_hack.crew=crew.id WHERE tournament_hack.crew <> 0 GROUP BY tournament_hack.crew HAVING sum(money_hack)>0 ORDER BY sum(money_hack) DESC LIMIT 100) as t JOIN user ON t.crew=user.crew GROUP BY user.crew HAVING count(user.crew)>2 ORDER BY total DESC) as t2');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['name']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"id\": \"".$row['crew']."\",\n"
				."\"score\": ".$row['total'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";
			
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t2.*,(SELECT username FROM user WHERE id=?) as username, (SELECT money FROM user WHERE id=?) as money,(SELECT count(id) FROM tournament_hack WHERE crew=(SELECT crew FROM user WHERE id=?)) as members,(SELECT sum(hack_count) FROM tournament_hack WHERE crew=(SELECT crew FROM user WHERE id=?)) as hack_count FROM (SELECT t.*,@curRank := @curRank + 1 AS rank FROM (SELECT t3.* FROM (SELECT crew,SUM(money_hack) as total,crew.name,crew.tag FROM `tournament_hack` JOIN crew ON tournament_hack.crew=crew.id WHERE crew <> 0 GROUP BY crew HAVING sum(money_hack)>0 ORDER BY sum(money_hack) DESC LIMIT 100) as t3 JOIN user on t3.crew=user.crew GROUP BY user.crew HAVING count(user.crew)>2 ORDER BY total DESC) as t) as t2 WHERE t2.crew=(SELECT crew FROM user WHERE id=?)');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->bindValue(4, $id, PDO::PARAM_INT);
			$stmt->bindValue(5, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"hack_left\": ".(($row['members']*100)-$row['hack_count']).",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['total'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT user.username, user.money,(SELECT count(id) FROM tournament_hack WHERE crew=(SELECT crew FROM user WHERE id=?)) as members,(SELECT sum(hack_count) FROM tournament_hack WHERE crew=(SELECT crew FROM user WHERE id=?)) as hack_count FROM user WHERE user.id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"hack_left\": ".(($row['members']*100)-$row['hack_count']).",\n"
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
			$stmt = $db->prepare('SELECT * FROM tournament_score_finish_crew');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['name']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"id\": \"".$row['crew']."\",\n"
				."\"score\": ".$row['diff'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";
			
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t.name, user.username, user.money, t.rank, t.diff FROM (SELECT * FROM tournament_score_finish_crew) as t JOIN user ON t.crew=user.crew WHERE user.id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"mscore\": ".$row['diff'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT username, money FROM user WHERE id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"mscore\": 0,\n";
				}				
			}
			$stmt = $db->prepare('SELECT username, money FROM user WHERE id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n";
				}	
			}
			$db->commit();			
		}
		elseif (($current==3) or (($current==0) and ($previous_type==3))) {
			//TOP100
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t2.*,@curRank := @curRank + 1 AS rank FROM (SELECT t.* FROM (SELECT tournament_hackdefend.crew,SUM(money_hack) as total,crew.name,crew.tag FROM `tournament_hackdefend` JOIN crew ON tournament_hackdefend.crew=crew.id WHERE tournament_hackdefend.crew <> 0 and hack_count>0 GROUP BY tournament_hackdefend.crew HAVING sum(hack_count)>0 ORDER BY sum(money_hack) DESC LIMIT 100) as t JOIN user ON t.crew=user.crew GROUP BY user.crew HAVING count(user.crew)>2 ORDER BY total DESC) as t2');
			$stmt->execute();
			$db->commit();
			$resp = "{\"ranks\":[\n";
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$resp = $resp."{\"user\": \"".$row['name']."\",\n"
				."\"crew\": \"".$row['tag']."\",\n"
				."\"id\": \"".$row['crew']."\",\n"
				."\"score\": ".$row['total'].",\n"
				."\"rank\": ".$row['rank']."\n},";
			}
			$resp = $resp."],";
			
			//Player Rank
			$db->beginTransaction();
			$stmt = $db->prepare('SET @curRank := 0;');
			$stmt->execute();
			$stmt = $db->prepare('SELECT t2.*,(SELECT username FROM user WHERE id=?) as username, (SELECT money FROM user WHERE id=?) as money,(SELECT count(id) FROM tournament_hackdefend WHERE crew=(SELECT crew FROM user WHERE id=?)) as members,(SELECT sum(hack_count) FROM tournament_hackdefend WHERE crew=(SELECT crew FROM user WHERE id=?)) as hack_count FROM (SELECT t.*,@curRank := @curRank + 1 AS rank FROM (SELECT t3.* FROM (SELECT crew,SUM(money_hack) as total,crew.name,crew.tag FROM `tournament_hackdefend` JOIN crew ON tournament_hackdefend.crew=crew.id WHERE crew <> 0 and hack_count>0 GROUP BY crew ORDER BY sum(money_hack) DESC LIMIT 100) as t3 JOIN user on t3.crew=user.crew GROUP BY user.crew HAVING count(user.crew)>2 ORDER BY total DESC) as t) as t2 WHERE t2.crew=(SELECT crew FROM user WHERE id=?)');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->bindValue(4, $id, PDO::PARAM_INT);
			$stmt->bindValue(5, $id, PDO::PARAM_INT);
			$stmt->execute();		
			if ($stmt->rowCount() != 0) { 
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": ".$row['rank'].",\n"
					."\"hack_left\": ".(($row['members']*100)-$row['hack_count']).",\n"
					."\"musername\": \"".$row['username']."\",\n"
					."\"mmoney\": ".$row['money'].",\n"
					."\"mscore\": ".$row['total'].",\n";
				}	
			}
			else {
				$stmt = $db->prepare('SELECT user.username, user.money,(SELECT count(id) FROM tournament_hackdefend WHERE crew=(SELECT crew FROM user WHERE id=?)) as members,(SELECT sum(hack_count) FROM tournament_hackdefend WHERE crew=(SELECT crew FROM user WHERE id=?)) as hack_count FROM user WHERE user.id=?');
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$resp = $resp."\"prank\": 0,\n"
					."\"hack_left\": ".(($row['members']*100)-$row['hack_count']).",\n"
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