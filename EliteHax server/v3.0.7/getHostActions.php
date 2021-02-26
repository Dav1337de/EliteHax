<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['host_id'])) or (!is_numeric($_POST['host_id']))) { exit(); }
	$host_id=$_POST['host_id'];
	
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_actions.*,(SELECT count(id) as web FROM `hack_scenario_services` WHERE host_id=244 and web=1) as web FROM hack_scenario_hosts join hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }

		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$resp = "{\"hacked\": ".$row['hacked'].",\n"
			."\"web\": ".$row['web'].",\n"
			."\"keylogger\": ".$row['keylogger'].",\n"
			."\"proxy\": ".$row['proxy'].",\n"
			."\"exploitkit\": ".$row['exploitkit'].",\n"
			."\"dataexfiltration\": ".$row['dataexfiltration'].",\n"
			."\"dumpdb\": ".$row['dumpdb'].",\n"
			."\"alterdata\": ".$row['alterdata'].",\n"
			."\"shutdown\": ".$row['shutdown'].",\n"
			."\"defacement\": ".$row['defacement'].",\n"
			."\"ransomware\": ".$row['ransomware'].",\n"
			."\"last_message\": \"".$row['last_message']."\",\n";
		}
		
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