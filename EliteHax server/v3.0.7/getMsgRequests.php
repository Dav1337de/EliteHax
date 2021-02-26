<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT username,timestamp FROM msg_request JOIN user ON msg_request.src=user.uuid WHERE msg_request.dst IN (SELECT uuid FROM user WHERE id=?) ORDER BY timestamp DESC"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"requests\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"username\": \"".$row['username']."\"\n},";
		}
		$resp = $resp."],\n";
		//Counters
		$stmt = $db->prepare('SELECT count(id) as new_msg FROM `private_chat` WHERE (uuid2=(SELECT uuid FROM user WHERE id=?)) and seen=0');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$new_msg=$row['new_msg'];			
		}		
		$stmt = $db->prepare('SELECT count(id) as new_req FROM msg_request WHERE msg_request.dst=(SELECT uuid FROM user WHERE id=?)');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$new_requests = $row['new_req'];		
		}		
		$stmt = $db->prepare("SELECT username,money FROM user WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp=$resp."\"username\": \"".$row['username']."\",\n"
			."\"new_msg\": \"".$new_msg."\",\n"	
			."\"new_req\": \"".$new_requests."\",\n"
			."\"money\": ".$row['money']."\n}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>