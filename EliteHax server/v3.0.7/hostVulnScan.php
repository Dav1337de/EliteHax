<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['host_id'])) or (!is_numeric($_POST['host_id']))) { exit(); }
	$host_id=$_POST['host_id'];
	
	try {
		$id = getIdFromToken($db);
		
		//Running Activities
		$running_activity=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { exit(base64_encode("{\"status\": \"OK\",\n}")); }
		
		$stmt = $db->prepare("SELECT * FROM `hack_scenario_hosts` WHERE id=? and user_id=?");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
				
		//Insert action with 30 Minutes delay (Average: 5 services, 2 minutes + 2 minutes + 2 minutes)
		$stmt = $db->prepare("INSERT INTO hack_scenario_activities (activity, user_id, host_id, description, start_time, end_time) VALUES (6,?,?,'Host Vulnerability Scan',NOW(),DATE_ADD(NOW(),INTERVAL 30 MINUTE))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE hack_scenario_hosts SET discovered=1,port_scanned=1,fingerprinted=1,vuln_scanned=1 WHERE id=? and user_id=?");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();

		$resp = "{\"status\": \"OK\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>