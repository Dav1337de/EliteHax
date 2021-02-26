<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT crew.id,crew.name,crew.tag FROM crew_invitation JOIN crew ON crew_invitation.crew_id=crew.id WHERE crew_invitation.user_id=? order by crew.tag asc"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"invitation\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"id\": \"".$row['id']."\","
			."\"name\": \"".$row['name']."\","
			."\"tag\": \"".$row['tag']."\""
			."},\n";
		}
		$resp = $resp."],";
		$stmt = $db->prepare('SELECT username,money FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"user\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n}";			
		}		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>