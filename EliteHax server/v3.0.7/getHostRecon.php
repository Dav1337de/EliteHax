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
				
		//General info
		$stmt = $db->prepare("SELECT * FROM (SELECT hack_scenario_hosts.*,SUM(hack_scenario_services.discovered=1) as services FROM hack_scenario_hosts JOIN hack_scenario_services ON hack_scenario_services.host_id=hack_scenario_hosts.id WHERE hack_scenario_hosts.user_id=? and hack_scenario_hosts.id=?) as t1 JOIN (SELECT hack_scenario_hosts.id as id2,SUM(hack_scenario_vulnerabilities.discovered=1 and hack_scenario_vulnerabilities.vuln_severity<>'I') as vulns FROM hack_scenario_hosts JOIN hack_scenario_vulnerabilities ON hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_hosts.user_id=? and hack_scenario_hosts.id=?) as t2 ON t1.id = t2.id2");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp
			."{\"hostname\": \"".$row['hostname']."\",\n"
			."\"services\": ".$row['services'].",\n"
			."\"vulns\": ".$row['vulns'].",\n";		
			
			if ($row['fingerprinted']==1) {
				$resp = $resp."\"os\": \"".getOsName($row['os'],$row['type'])."\",\n";
			}
			else {
				$resp = $resp."\"os\": \"Unknown\",\n";
			}
		}
		
		//Discovered Users
		$stmt = $db->prepare("SELECT * FROM hack_scenario_users WHERE user_id=? and visible=1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$usersN=0;
		$resp = $resp . "\"users\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$usersN++;
			$resp = $resp."{\"firstname\": \"".$row['firstname']."\",\n"
			."\"lastname\": \"".$row['lastname']."\",\n"
			."\"role\": \"".$row['role']."\",\n},";
		}		
		$resp = $resp."]\n,"
		."\"usersN\": ".$usersN.",\n";
		
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
		
		//User&Money
		$stmt = $db->prepare('SELECT username,money FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$resp = $resp."\"user\": \"".$row['username']."\",\n"		
			."\"money\": ".$row['money']."\n}";			
		}		
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>