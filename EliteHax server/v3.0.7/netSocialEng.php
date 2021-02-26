<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['net_id'])) or (!is_numeric($_POST['net_id']))) { exit(); }
	$net_id=$_POST['net_id'];
	
	try {
		$id = getIdFromToken($db);
		
		//Running Activities
		$running_activity=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) { exit(base64_encode("{\"status\": \"OK\",\n}")); }
				
		//Insert action with 60 Minutes delay
		$stmt = $db->prepare("INSERT INTO hack_scenario_activities (activity, user_id, net_id, description, start_time, end_time) VALUES (3,?,?,'Social Engineering',NOW(),DATE_ADD(NOW(),INTERVAL 60 MINUTE))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $net_id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE hack_scenario_networks SET social_engineering=1 WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	

		$resp = "{\"status\": \"OK\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>