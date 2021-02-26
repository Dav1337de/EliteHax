<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['host_id'])) or (!is_numeric($_POST['host_id']))) { exit(); }
	$host_id=$_POST['host_id'];
	
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT down FROM `hack_scenario_hosts` WHERE id=? and user_id=?");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n\"down\": ".$row['down'].",\n";
		}	
				
		$stmt = $db->prepare("SELECT hack_scenario_vulnerabilities.id,hack_scenario_vulnerabilities.bruteforcedUser,hack_scenario_vulnerabilities.bruteforcedPass,hack_scenario_vulnerabilities.vuln_name,hack_scenario_vulnerabilities.vuln_severity,hack_scenario_vulnerabilities.discovered,hack_scenario_vulnerabilities.exploited,hack_scenario_services.login FROM `hack_scenario_vulnerabilities` JOIN hack_scenario_services ON hack_scenario_vulnerabilities.service_id=hack_scenario_services.id WHERE hack_scenario_vulnerabilities.host_id=? and hack_scenario_vulnerabilities.vuln_severity<>'I' order by FIELD(vuln_severity, 'C','H','M','L','I')");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = $resp."\"vulns\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['discovered']==1) {
				$resp = $resp."{\"vuln_name\": \"".$row['vuln_name']."\",\n"
				."\"vuln_id\": \"".$row['id']."\",\n"
				."\"vuln_login\": \"".$row['login']."\",\n"
				."\"vuln_exploited\": ".$row['exploited'].",\n"
				."\"bruteforcedUser\": ".$row['bruteforcedUser'].",\n"
				."\"bruteforcedPass\": ".$row['bruteforcedPass'].",\n"
				."\"vuln_severity\": \"".$row['vuln_severity']."\"\n},";
			}
		}		
		$resp = $resp."],\n";
		
		//Activity
		$description="";
		$total_time=0;
		$time_left=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {		
				$description=$row['description'];
				$time_left=$row['time_left'];
				$total_time=$row['total_time'];	
			}	
		}
		$resp = $resp."\"task_description\": \"".$description."\",\n"		
		."\"task_time_left\": ".$time_left.",\n"
		."\"task_total_time\": ".$total_time.",\n";	
		
		//Running Activities
		$running_activity=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) {
			$running_activity=1;
		}
		$resp=$resp."\"running_activity\": ".$running_activity."\n}";

		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>