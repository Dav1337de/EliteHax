<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("SELECT crew,crew.name FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
			$crew_name = $row['name'];
		}

		$stmt = $db->prepare("SELECT crew_chat.message,crew_chat.user_id,user.username,DATE_SUB(crew_chat.timestamp,INTERVAL 1 HOUR) as timestamp FROM crew_chat LEFT JOIN user ON crew_chat.user_id = user.id WHERE crew_id=? and user_id<>0"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();

		$resp = "{\"crew_chats\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"msg\": \"".$row['message']."\",\n"
			."\"timestamp\": \"".$row['timestamp']."\",\n";
			if ($row['username'] === NULL) { $resp = $resp."\"username\": \"".$crew_name."\",\n\"system\": \"Y\",\n"; }
			else { $resp = $resp."\"username\": \"".$row['username']."\",\n\"system\": \"N\",\n"; }
			if ($row['user_id'] == $id) { $resp = $resp."\"mine\": \"Y\"\n},"; }
			else { $resp = $resp."\"mine\": \"N\"\n},"; }
		}
		$resp = $resp."]}";
		//echo $resp;
		echo base64_encode($resp);		
		
		$stmt = $db->prepare("UPDATE user SET crew_chat_timestamp=NOW() WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>