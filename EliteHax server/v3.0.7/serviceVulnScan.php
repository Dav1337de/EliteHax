<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['service_id'])) or (!is_numeric($_POST['service_id']))) { exit(); }
	$service_id=$_POST['service_id'];
	
	try {
		$id = getIdFromToken($db);
		
		//Running Activities
		$running_activity=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { exit(base64_encode("{\"status\": \"OK\",\n}")); }
		
		$stmt = $db->prepare("SELECT hack_scenario_services.host_id,hack_scenario_services.fingerprinted FROM `hack_scenario_services` JOIN hack_scenario_hosts ON hack_scenario_services.host_id=hack_scenario_hosts.id WHERE hack_scenario_services.id=? and hack_scenario_hosts.user_id=?");
		$stmt->bindValue(1, $service_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$host_id=$row['host_id'];
			$fingerprinted=$row['fingerprinted'];
		}
				
		//Insert action with 3 or 5 Minutes delay
		$time=5;
		if ($fingerprinted==1) { $time=3; }
		$stmt = $db->prepare("INSERT INTO hack_scenario_activities (activity, user_id, service_id, description, start_time, end_time) VALUES (8,?,?,'Service Vulnerability Scan',NOW(),DATE_ADD(NOW(),INTERVAL ? MINUTE))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $service_id, PDO::PARAM_INT);
		$stmt->bindValue(3, $time, PDO::PARAM_INT);
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