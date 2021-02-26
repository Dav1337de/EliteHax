<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//Init Arrays
		$hostnames=["","","","","","","","","","","",""];
		$os=[0,0,0,0,0,0,0,0,0,0,0,0];
		$discovered=[0,0,0,0,0,0,0,0,0,0,0,0];
		$hacked=[0,0,0,0,0,0,0,0,0,0,0,0];
		$down=[0,0,0,0,0,0,0,0,0,0,0,0];
		$proxied=[0,0,0,0,0,0,0,0,0,0,0,0];
		$ids=[0,0,0,0,0,0,0,0,0,0,0,0];
		$services=[0,0,0,0,0,0,0,0,0,0,0,0];
		$vulns=[0,0,0,0,0,0,0,0,0,0,0,0];
				
		$stmt = $db->prepare("SELECT * FROM (SELECT hack_scenario_hosts.*,SUM(hack_scenario_services.discovered=1) as services FROM hack_scenario_hosts JOIN hack_scenario_services ON hack_scenario_services.host_id=hack_scenario_hosts.id WHERE hack_scenario_hosts.user_id=? group by hack_scenario_hosts.id) as t1 JOIN (SELECT hack_scenario_hosts.id as id2,SUM(hack_scenario_vulnerabilities.discovered=1 and hack_scenario_vulnerabilities.vuln_severity<>?) as vulns FROM hack_scenario_hosts JOIN hack_scenario_vulnerabilities ON hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_hosts.user_id=? group by hack_scenario_hosts.id) as t2 ON t1.id = t2.id2");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, "I", PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$pos=$row['pos'];
			$type=$row['type'];
			$typepos=0;
			if ($type=="int") { $typepos=3; }
			elseif ($type=="client") { $typepos=6; }
			elseif ($type=="int2") { $typepos=9; }
			$arraypos = $pos+$typepos-1;
			
			$ids[$arraypos]=$row['id'];
			$hostnames[$arraypos]=$row['hostname'];
			$os[$arraypos]=$row['os'];
			$services[$arraypos]=$row['services'];
			$discovered[$arraypos]=$row['discovered'];
			$hacked[$arraypos]=$row['hacked'];
			$vulns[$arraypos]=$row['vulns'];
			$down[$arraypos]=$row['down'];
			$proxied[$arraypos]=$row['proxy'];
		}
		$resp = "{\"hosts\":[\n";
		for ($i=1;$i<=12;$i++) {
			if ($discovered[($i-1)]==1) {
				$resp = $resp
				."{\"hostname\": \"".$hostnames[($i-1)]."\",\n"
				."\"id\": ".$ids[($i-1)].",\n"
				."\"os\": ".$os[($i-1)].",\n"
				."\"services\": ".$services[($i-1)].",\n"
				."\"vulns\": ".$vulns[($i-1)].",\n"
				."\"proxied\": ".$proxied[($i-1)].",\n"
				."\"down\": ".$down[($i-1)].",\n"
				."\"discovered\": ".$discovered[($i-1)].",\n"
				."\"hacked\": ".$hacked[($i-1)].",\n},";
			} else {
				$resp = $resp
				."{\"hostname\": \"\",\n"
				."\"id\": \"\",\n"
				."\"os\": \"\",\n"
				."\"services\": \"\",\n"
				."\"vulns\": \"\",\n"
				."\"proxied\": \"\",\n"
				."\"down\": \"\",\n"
				."\"discovered\": \"\",\n"
				."\"hacked\": \"\",\n},";
			}
		}
		$resp = $resp."],\n";
		
		//Networks
		$stmt = $db->prepare('SELECT * FROM (SELECT hack_scenario_networks.*,SUM(hack_scenario_services.discovered=1) as services FROM hack_scenario_networks JOIN hack_scenario_hosts ON hack_scenario_hosts.user_id=hack_scenario_networks.user_id JOIN hack_scenario_services ON hack_scenario_services.host_id=hack_scenario_hosts.id WHERE hack_scenario_hosts.type=hack_scenario_networks.type and hack_scenario_networks.user_id=? group by hack_scenario_networks.id) as t1 JOIN (SELECT hack_scenario_networks.id as id2, SUM(hack_scenario_vulnerabilities.discovered=1 and hack_scenario_vulnerabilities.vuln_severity<>?) as vulns FROM hack_scenario_networks JOIN hack_scenario_hosts ON hack_scenario_hosts.user_id=hack_scenario_networks.user_id JOIN hack_scenario_vulnerabilities ON hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_hosts.type=hack_scenario_networks.type and hack_scenario_networks.user_id=? group by hack_scenario_networks.id) as t2 ON t1.id=t2.id2');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, "I", PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['type']=="dmz") {
				$resp = $resp."\"dmz_id\": ".$row['id'].",\n"
				."\"dmz_services\": ".$row['services'].",\n"
				."\"dmz_vulns\": ".$row['vulns'].",\n"
				."\"dmz_name\": \"".$row['name']."\",\n";
			}		
			elseif ($row['type']=="int") {
				if ($row['visible']==0) {
					$resp = $resp."\"int_id\": 0,\n";
				}
				else {
					$resp = $resp."\"int_id\": ".$row['id'].",\n"
					."\"int_services\": ".$row['services'].",\n"
					."\"int_vulns\": ".$row['vulns'].",\n"
					."\"int_name\": \"".$row['name']."\",\n";
				}
			}
			elseif ($row['type']=="client") {
				if ($row['visible']==0) {
					$resp = $resp."\"client_id\": 0,\n";
				}
				else {
					$resp = $resp."\"client_id\": ".$row['id'].",\n"
					."\"client_services\": ".$row['services'].",\n"
					."\"client_vulns\": ".$row['vulns'].",\n"
					."\"client_name\": \"".$row['name']."\",\n";
				}
			}
			elseif ($row['type']=="int2") {
				if ($row['visible']==0) {
					$resp = $resp."\"int2_id\": 0,\n";
				}
				else {
					$resp = $resp."\"int2_id\": ".$row['id'].",\n"
					."\"int2_services\": ".$row['services'].",\n"
					."\"int2_vulns\": ".$row['vulns'].",\n"
					."\"int2_name\": \"".$row['name']."\",\n";
				}
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