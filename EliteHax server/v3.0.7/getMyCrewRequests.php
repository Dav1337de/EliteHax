<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT user.crew,user.username,user.money,user.crew_role,crew.name FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
			$my_role = $row['crew_role'];
			$crew_name = $row['name'];
			$username = $row['username'];
			$money = $row['money'];
		}
		if ($my_role > 4) { exit("An Error occured!"); }
		
		$stmt = $db->prepare("SELECT user.id,user.username,user.score,user.missions_rep FROM user JOIN crew_requests ON user.id=crew_requests.user_id WHERE user.id IN (SELECT user_id FROM crew_requests WHERE crew_id=?) AND crew_id=? ORDER BY crew_role ASC, score DESC"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"requests\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp
			."{\"username\": \"".$row['username']."\",\n"
			."\"player_id\": \"".$row['id']."\",\n"
			."\"score\": \"".$row['score']."\",\n"
			."\"reputation\": \"".$row['missions_rep']."\"\n},";
		}
		$resp = $resp."],\n"
		."\"crew_name\": \"".$crew_name."\",\n"
		."\"username\": \"".$username."\",\n"
		."\"money\": ".$money.",\n"
		."\"my_role\": ".$my_role."\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>