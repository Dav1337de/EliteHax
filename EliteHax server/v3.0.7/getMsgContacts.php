<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT username,timestamp FROM msg_contacts JOIN user ON msg_contacts.contact=user.uuid WHERE msg_contacts.uuid IN (SELECT uuid FROM user WHERE id=?) ORDER BY username"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"contacts\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"username\": \"".$row['username']."\"\n},";
		}
		$resp = $resp."],\n";
		$stmt = $db->prepare("SELECT username,money FROM user WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp=$resp."\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money']."\n}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>