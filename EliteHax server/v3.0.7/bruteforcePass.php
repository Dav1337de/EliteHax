<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['vuln_id'])) or (!is_numeric($_POST['vuln_id']))) { exit(); }
	$vuln_id=$_POST['vuln_id'];
	
	try {
		$id = getIdFromToken($db);
		
		//Running Activities
		$running_activity=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { exit(base64_encode("{\"status\": \"OK\",\n}")); }
		
		$stmt = $db->prepare("SELECT hack_scenario_vulnerabilities.* FROM hack_scenario_vulnerabilities JOIN hack_scenario_hosts on hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_vulnerabilities.id=? and hack_scenario_hosts.user_id=? and hack_scenario_vulnerabilities.discovered=1");
		$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
		
		//Insert action with 10 Minutes delay
		$stmt = $db->prepare("INSERT INTO hack_scenario_activities (activity, user_id, vuln_id, description, start_time, end_time) VALUES (11,?,?,'Bruteforce Passwords',NOW(),DATE_ADD(NOW(),INTERVAL 10 MINUTE))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $vuln_id, PDO::PARAM_INT);
		$stmt->execute();
				
		$resp = "{\"status\": \"OK\",\n}";

		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>