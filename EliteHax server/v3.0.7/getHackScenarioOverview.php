<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
				
		$stmt = $db->prepare("SELECT *,TIMESTAMPDIFF(SECOND,NOW(),end_time) as end FROM hack_scenario_missions WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(base64_encode("{\"status\": \"RENEW\",\n}")); }
		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$desc=$row['description'];
			$completed=$row['completed'];
			$rep=$row['rep'];
			$end=$row['end'];
		}
		
		//User&Money
		$stmt = $db->prepare('SELECT username,money FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"		
			."\"money\": ".$row['money'].",\n"
			."\"desc\": \"".$desc."\",\n"
			."\"completed\": ".$completed.",\n"
			."\"rep\": ".$rep.",\n"
			."\"end\": ".$end.",\n}";
		}		
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>