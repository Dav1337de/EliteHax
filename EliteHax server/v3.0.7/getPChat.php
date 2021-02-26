<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		if (!isset($_POST['username'])) { exit(""); }
		$username=$_POST['username'];
		
		$stmt = $db->prepare("UPDATE private_chat SET seen=1 WHERE (uuid1=(SELECT uuid FROM user WHERE username=?) and uuid2=(SELECT uuid FROM user WHERE id=?))"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		

		$stmt = $db->prepare("SELECT * FROM (SELECT id,private_chat.message,private_chat.uuid1,private_chat.uuid2,DATE_SUB(private_chat.timestamp,INTERVAL 1 HOUR) as timestamp,(SELECT uuid FROM user WHERE id=?) as my_uuid FROM private_chat WHERE (uuid1=(SELECT uuid FROM user WHERE username=?) and uuid2=(SELECT uuid FROM user WHERE id=?)) OR (uuid1=(SELECT uuid FROM user WHERE id=?) and uuid2=(SELECT uuid FROM user WHERE username=?)) ORDER BY id DESC LIMIT 50) as t ORDER BY id ASC"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $username, PDO::PARAM_STR);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, $id, PDO::PARAM_INT);
		$stmt->bindValue(5, $username, PDO::PARAM_STR);
		$stmt->execute();

		$resp = "{\"private_chats\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"msg\": \"".$row['message']."\",\n"
			."\"timestamp\": \"".$row['timestamp']."\",\n";
			if ($row['uuid1'] == $row['my_uuid']) { $resp = $resp."\"mine\": \"Y\"\n},"; }
			else { $resp = $resp."\"mine\": \"N\"\n},"; }
		}
		$resp = $resp."]}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>