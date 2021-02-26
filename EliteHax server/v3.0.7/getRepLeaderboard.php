<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//TOP100
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT user.id, username, missions_rep, crew.tag, @curRank := @curRank + 1 AS rank FROM user LEFT JOIN crew ON user.crew=crew.id WHERE missions_rep>0 ORDER BY missions_rep DESC LIMIT 100');
		$stmt->execute();
		$db->commit();
		$resp = "{\"ranks\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"user\": \"".$row['username']."\",\n"
			."\"crew\": \"".$row['tag']."\",\n"
			."\"rank\": ".$row['rank'].",\n"
			."\"reputation\": ".$row['missions_rep']."\n},";
		}
		$resp = $resp."],";
		
		//Player Rank
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT username, money, rank, missions_rep FROM (SELECT id, username, money, missions_rep, @curRank := @curRank + 1 AS rank FROM user ORDER BY missions_rep DESC) as t WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();		
		$db->commit();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"prank\": ".$row['rank'].",\n"
			."\"musername\": \"".$row['username']."\",\n"
			."\"mmoney\": ".$row['money'].",\n"
			."\"mreputation\": ".$row['missions_rep']."}\n";
		}			
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>