<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['service_id'])) or (!is_numeric($_POST['service_id']))) { exit(); }
	$service_id=$_POST['service_id'];
	
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT * FROM `hack_scenario_services` JOIN hack_scenario_hosts ON hack_scenario_services.host_id=hack_scenario_hosts.id WHERE hack_scenario_services.id=? and hack_scenario_hosts.user_id=?");
		$stmt->bindValue(1, $service_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
				
		$stmt = $db->prepare("SELECT vuln_name,vuln_severity,discovered,exploited FROM `hack_scenario_vulnerabilities` WHERE service_id=?");
		$stmt->bindValue(1, $service_id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\"vulns\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['discovered']==1) {
				$resp = $resp."{\"vuln_name\": \"".$row['vuln_name']."\",\n"
				."\"vuln_exploited\": ".$row['exploited'].",\n"
				."\"vuln_severity\": \"".$row['vuln_severity']."\"\n},";
			}
		}		
		$resp = $resp."]\n}";

		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>