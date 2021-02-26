<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT crew.*,user.crew_role,user.username,user.money FROM crew JOIN user ON crew.id = user.crew WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_crew = $row['id'];
			$resp = "{\"name\": \"".$row['name']."\",\n"
			."\"id\": \"".$row['id']."\",\n"
			."\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"wallet\": ".$row['wallet'].",\n"
			."\"wallet_p\": ".$row['wallet_p'].",\n"
			."\"crew_role\": ".$row['crew_role'].",\n"
			."\"slot\": ".$row['slot'].",\n"
			."\"desc\": \"".$row['description']."\",\n"
			."\"tag\": \"".$row['tag']."\",\n";
		}
		//Crew Elite
		$stmt = $db->prepare("SELECT user.uuid,user.username FROM user JOIN crew ON user.crew=crew.id WHERE user.crew = (SELECT crew FROM user WHERE id=?) and user.crew_role = 2"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = $resp."\"elite\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp
			."{\"username\": \"".$row['username']."\",\n"
			."\"player_id\": \"".$row['uuid']."\",\n},";
		}
		$resp = $resp."],\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>