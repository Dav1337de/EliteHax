<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['net_id'])) or (!is_numeric($_POST['net_id']))) { exit(); }
	$net_id=$_POST['net_id'];
	
	try {
		$id = getIdFromToken($db);
				
		$stmt = $db->prepare("SELECT * FROM hack_scenario_networks WHERE user_id=? and id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $net_id, PDO::PARAM_INT);
		$stmt->execute();

		//Activities
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$net_name=$row['name'];
			$net_id=$row['id'];
			$host_scan=$row['host_scan'];
			$port_scan=$row['port_scan'];
			$social_engineering=$row['social_engineering'];
		}		
		
		//Number of hosts
		$stmt = $db->prepare("SELECT COUNT(id) as hosts FROM hack_scenario_hosts WHERE type=(SELECT type FROM hack_scenario_networks WHERE id=? and user_id=?) and user_id=? and discovered=1");
		$stmt->bindValue(1, $net_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();

		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$hosts=$row['hosts'];
		}

		//Number of services
		$stmt = $db->prepare("SELECT count(id) as services from hack_scenario_services WHERE host_id in (SELECT id FROM hack_scenario_hosts WHERE type=(SELECT type FROM hack_scenario_networks WHERE id=? and user_id=?) and user_id=?) and discovered=1");
		$stmt->bindValue(1, $net_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();

		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$services=$row['services'];
		}
		
		//Number of users
		$stmt = $db->prepare("SELECT COUNT(id) as users FROM hack_scenario_users WHERE user_id=? and visible=1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$users=$row['users'];
		}
		
		//Running Activities
		$running_activity=0;
		$stmt = $db->prepare('SELECT description,TIMESTAMPDIFF(SECOND,NOW(),end_time) as time_left,TIMESTAMPDIFF(SECOND,start_time,end_time) as total_time FROM hack_scenario_activities WHERE user_id=? and completed=0 ORDER BY end_time DESC LIMIT 1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()>0) {
			$running_activity=1;
		}
		
		$resp = "{\"net_id\": ".$net_id.",\n"		
		."\"net_name\": \"".$net_name."\",\n"
		."\"host_scan\": ".$host_scan.",\n"
		."\"port_scan\": ".$port_scan.",\n"
		."\"social_engineering\": ".$social_engineering.",\n"
		."\"hosts\": ".$hosts.",\n"
		."\"services\": ".$services.",\n"
		."\"users\": ".$users.",\n"
		."\"running_activity\": ".$running_activity."\n"
		."}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>