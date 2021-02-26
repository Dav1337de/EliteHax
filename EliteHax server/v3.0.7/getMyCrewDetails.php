<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT crew.*,user.crew_role,user.crew_daily_contribution,user.username,user.money FROM crew JOIN user ON crew.id = user.crew WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_crew = $row['id'];
			$resp = "{\"name\": \"".$row['name']."\",\n"
			."\"id\": \"".$row['id']."\",\n"
			."\"wallet\": ".$row['wallet'].",\n"
			."\"wallet_p\": ".$row['wallet_p'].",\n"
			."\"daily_wallet\": ".$row['daily_wallet'].",\n"
			."\"crew_daily_contribution\": ".$row['crew_daily_contribution'].",\n"
			."\"crew_role\": ".$row['crew_role'].",\n"
			."\"tournament_best\": ".$row['tournament_best'].",\n"
			."\"tournament_won\": ".$row['tournament_won'].",\n"
			."\"slot\": ".$row['slot'].",\n"
			."\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"desc\": \"".$row['description']."\",\n"
			."\"tag\": \"".$row['tag']."\",\n";
		}
		//Requests
		$stmt = $db->prepare('SELECT count(user_id) as requests FROM crew_requests WHERE crew_id=?');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"requests\": ".$row['requests'].",\n";
		}	
		//Crew Chat
		$stmt = $db->prepare('SELECT count(id) as msgs FROM crew_chat WHERE crew_id=? and user_id<>0 and timestamp>(SELECT crew_chat_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"crew_chats\": ".$row['msgs'].",\n";
		}	
		//Crew Logs
		$stmt = $db->prepare('SELECT count(id) as count FROM `datacenter_attack_logs` WHERE (attacking_crew=? or datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)) and attack_status=3 and result=1 and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countWar=$row['count'];
		}	
		$stmt = $db->prepare('SELECT count(id) as count FROM crew_logs WHERE crew_id=? and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countEvents=$row['count'];
		}	
		$resp = $resp."\"crew_logs\": ".($countWar+$countEvents).",\n";
		//Crew Rank
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT crew, members, score, reputation, rank FROM (SELECT crew, members, score, reputation, @curRank := @curRank + 1 AS rank FROM (SELECT crew, COUNT(id) as members, SUM(score) as score, SUM(reputation) as reputation FROM user WHERE crew <> 0 GROUP BY crew ORDER BY sum(reputation+score) DESC LIMIT 10000) as t) as t2 WHERE crew=?');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
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