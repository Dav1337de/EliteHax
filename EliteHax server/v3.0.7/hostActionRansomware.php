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
		
		$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_actions.ransomware FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
		
		//Insert action with 60 Minutes delay
		$stmt = $db->prepare("INSERT INTO hack_scenario_activities (activity, user_id, host_id, description, start_time, end_time) VALUES (20,?,?,'Installing Ransomware',NOW(),DATE_ADD(NOW(),INTERVAL 60 MINUTE))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();

		$resp = "{\"status\": \"OK\"\n}";

		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>