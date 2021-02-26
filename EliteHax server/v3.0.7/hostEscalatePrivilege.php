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
		
		$stmt = $db->prepare("SELECT hacked,escalated FROM hack_scenario_hosts WHERE user_id=? and id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Check Hacking&Escalation Status
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			//Not Yet Hacked		
			if ($row['hacked']==0) { exit(""); }
			//Already Escalated
			elseif ($row['escalated']==1) { exit(""); }
		}	
		
		//Insert action with 10 Minutes delay
		$stmt = $db->prepare("INSERT INTO hack_scenario_activities (activity, user_id, host_id, description, start_time, end_time) VALUES (14,?,?,'Escalating Privileges',NOW(),DATE_ADD(NOW(),INTERVAL 10 MINUTE))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();

		$resp = "{\"status\": \"OK\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>