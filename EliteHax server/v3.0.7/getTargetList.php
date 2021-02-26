<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT * FROM target_list WHERE user_id=? order by name asc"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"targets\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"name\": \"".$row['name']."\","
			."\"ip\": \"".long2ip($row['ip'])."\","
			."\"desc\": \"".$row['description']."\""
			."},\n";
		}
		$resp = $resp."]}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>