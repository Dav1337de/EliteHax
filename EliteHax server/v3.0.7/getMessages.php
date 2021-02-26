<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT private_chat.message,DATE_SUB(private_chat.timestamp,INTERVAL 1 HOUR) as timestamp,private_chat.seen,u1.username as tx,u1.id as id1,u2.username as rx,u2.id as id2 FROM private_chat JOIN (SELECT MAX(id) as id FROM (SELECT MAX(id) as id,uuid1,uuid2 FROM `private_chat` WHERE (uuid1=(SELECT uuid FROM user WHERE id=?) or uuid2=(SELECT uuid FROM user WHERE id=?)) and uuid1>=uuid2 group by uuid1,uuid2 UNION SELECT MAX(id) as id,uuid2,uuid1 FROM `private_chat` WHERE (uuid1=(SELECT uuid FROM user WHERE id=?) or uuid2=(SELECT uuid FROM user WHERE id=?)) and uuid1<uuid2 group by uuid2,uuid1) as t group by uuid1,uuid2) as t2 on private_chat.id=t2.id JOIN user as u1 ON u1.uuid=private_chat.uuid1 JOIN user as u2 ON u2.uuid=private_chat.uuid2 ORDER BY timestamp DESC"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"messages\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['id1'] == $id) {
				$username = $row['rx'];
				$seen = 1;
			} else {
				$username = $row['tx'];
				$seen = $row['seen'];
			}
			$resp = $resp."{\"username\": \"".$username."\",\n"
			."\"message\": \"".$row['message']."\",\n"
			."\"timestamp\": \"".$row['timestamp']."\",\n"
			."\"seen\": ".$seen."\n"
			."},";
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