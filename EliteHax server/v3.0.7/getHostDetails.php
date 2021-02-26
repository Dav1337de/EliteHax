<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['host_id'])) or (!is_numeric($_POST['host_id']))) { exit(); }
	$host_id=$_POST['host_id'];
	
	function getOsName($os,$type) {
		$OSNameDMZ = array("EliteHax OS","OpenEH","EliteHax Server 2018");
		$OSNameINT = array("EliteHax OS","OpenEH","EliteHax Server 2018");
		$OSNameClient = array("EliteHax OS","OpenEH","EliteHax Client 2k18");
		$OSNameINT2 = array("EliteHax OS","OpenEH","EliteHax Server 2018","EliteHax Client 2k18");
		if ($type=="dmz") { return $OSNameDMZ[$os-1]; }
		elseif ($type=="int") { return $OSNameINT[$os-1]; }
		elseif ($type=="client") { return $OSNameClient[$os-1]; }
		elseif ($type=="int2") { return $OSNameINT2[$os-1]; }
	}
	
	try {
		$id = getIdFromToken($db);
				
		$stmt = $db->prepare("SELECT hack_scenario_services.*,hack_scenario_vulnerabilities.vuln_severity,hack_scenario_vulnerabilities.discovered as vdiscovered FROM hack_scenario_hosts join hack_scenario_services ON hack_scenario_hosts.id=hack_scenario_services.host_id JOIN hack_scenario_vulnerabilities ON hack_scenario_services.id=hack_scenario_vulnerabilities.service_id WHERE hack_scenario_hosts.user_id=? and hack_scenario_hosts.id=? group by hack_scenario_services.id order by hack_scenario_services.service_port+0");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		
		$discoveredServices=0;
		if ($stmt->rowCount()==0) { exit(); }
		$resp = "{\"services\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['discovered']==1) {
				$resp = $resp."{\"id\": ".$row['id'].",\n"		
				."\"service_port\": \"".$row['service_port']."\",\n";
				if ($row['fingerprinted']==1) {
					$resp = $resp."\"service_name\": \"".$row['service_name']."\",\n";
				}
				else {
					$resp = $resp."\"service_name\": \"\",\n";
				}
				if ($row['vdiscovered']==1) {
					$resp = $resp."\"vulnerability\": \"".$row['vuln_severity']."\",\n";
				}
				else {
					$resp = $resp."\"vulnerability\": \"\",\n";
				}
				$resp=$resp."},";			
				$discoveredServices++;
			}
		}		
		$resp = $resp."],\n";
		
		$stmt = $db->prepare('SELECT hack_scenario_hosts.* FROM hack_scenario_hosts WHERE user_id=? and id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"port_scanned\": ".$row['port_scanned'].",\n"
			."\"fingerprinted\": ".$row['fingerprinted'].",\n"
			."\"hacked\": ".$row['hacked'].",\n"
			."\"down\": ".$row['down'].",\n"
			."\"vuln_scanned\": ".$row['vuln_scanned'].",\n";
			if ($row['fingerprinted']==1) {
				$resp = $resp."\"os\": \"".getOsName($row['os'],$row['type'])."\",\n";
			}
			else {
				$resp = $resp."\"os\": \"\",\n";
			}
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
		
		$resp=$resp."\"running_activity\": ".$running_activity."\n"
		."\n}";	
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>