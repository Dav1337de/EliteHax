<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("SELECT tournaments_new.*,CURTIME(),TIME_TO_SEC(SUBTIME(time_start,CURTIME())) as next,TIME_TO_SEC(SUBTIME(time_end,CURTIME())) as current FROM `tournaments_new` WHERE CURTIME()<time_end ORDER BY time_end LIMIT 2");
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($i==1) {
				$type = $row['type'];
				$current = $row['current'];
				$i++;
			}
			else {
				$next_type = $row['type'];
				$next_time = $row['next'];
			}
		}
		if ($stmt->rowCount() == 1) { 
			$next_type=1;
			$next_time=$current+1;
		}
		$resp = "{\n"
		."\"type\": ".$type.",\n"
		."\"current\": \"".$current."\",\n"
		."\"next_type\": ".$next_type.",\n"
		."\"next_time\": \"".$next_time."\",\n";
		
		$stmt = $db->prepare("SELECT username,money FROM user WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp=$resp."\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money']."\n";
		}
		
		$resp = $resp."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>