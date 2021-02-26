<?php
	include 'db.php';
	include 'validate.php';
	
	try {
		$id = getIdFromToken($db);
				
		//Retrieve Activity and Details
		$stmt = $db->prepare("SELECT * FROM hack_scenario_activities WHERE user_id=? and completed=0 and TIMESTAMPDIFF(SECOND,NOW(),end_time)<=0 ORDER BY end_time DESC LIMIT 1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(base64_encode("{\"status\": \"OK\",\n}")); }
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$activity=$row['activity'];
			$net_id=$row['net_id'];
			$host_id=$row['host_id'];
			$service_id=$row['service_id'];
			$vuln_id=$row['vuln_id'];
		}
		
		//Network Host Scan
		if ($activity==1) {
			$stmt = $db->prepare("UPDATE hack_scenario_hosts SET discovered=1 WHERE type=(SELECT type FROM `hack_scenario_networks` WHERE id=? and user_id=?) and user_id=?");
			$stmt->bindValue(1, $net_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Network Port Scan
		elseif ($activity==2) {
			$stmt = $db->prepare("UPDATE hack_scenario_hosts SET port_scanned=1,discovered=1 WHERE type=(SELECT type FROM `hack_scenario_networks` WHERE id=? and user_id=?) and user_id=?");
			$stmt->bindValue(1, $net_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("UPDATE hack_scenario_services SET discovered=1 WHERE host_id in (SELECT id FROM hack_scenario_hosts WHERE type=(SELECT type FROM hack_scenario_networks WHERE id=? and user_id=?) and user_id=?)");
			$stmt->bindValue(1, $net_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Social Engineering
		elseif ($activity==3) {
			$stmt = $db->prepare("UPDATE hack_scenario_users SET visible=1 WHERE user_id=? and canSocial=1");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();		
			
			$stmt = $db->prepare("UPDATE hack_scenario_users SET social=1 WHERE user_id=? and canSocial=1");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$db->beginTransaction();
			$stmt = $db->prepare("UPDATE hack_scenario_hosts SET discovered=1,hacked=1,proxy=1 WHERE id in (SELECT host_id FROM hack_scenario_users where user_id=? and canSocial=1)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$db->commit();
			
			$stmt = $db->prepare("UPDATE hack_scenario_actions SET proxy=1 WHERE proxy=0 and user_id=? and host_id IN (SELECT id FROM `hack_scenario_hosts` WHERE user_id=? and proxy=1)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			if ($stmt->rowCount()>0) {
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+10 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+10 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			
			$stmt = $db->prepare("UPDATE hack_scenario_networks SET visible=1 WHERE type in (SELECT distinct type FROM `hack_scenario_hosts` WHERE discovered=1 and user_id=?) and user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();	
		}
		//Host Port Scan
		elseif ($activity==4) {
			$stmt = $db->prepare("UPDATE hack_scenario_services SET discovered=1 WHERE host_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Host Fingerprint
		elseif ($activity==5) {
			$stmt = $db->prepare("UPDATE hack_scenario_services SET discovered=1,fingerprinted=1 WHERE host_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Host Vulnerability Scan
		elseif ($activity==6) {
			$stmt = $db->prepare("UPDATE hack_scenario_services SET discovered=1,fingerprinted=1 WHERE host_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET discovered=1 WHERE host_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Service Fingerprint
		elseif ($activity==7) {
			$stmt = $db->prepare("UPDATE hack_scenario_services SET discovered=1,fingerprinted=1 WHERE id=?");
			$stmt->bindValue(1, $service_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Service Vulnerability Scan
		elseif ($activity==8) {
			$stmt = $db->prepare("UPDATE hack_scenario_services SET discovered=1,fingerprinted=1 WHERE id=?");
			$stmt->bindValue(1, $service_id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET discovered=1 WHERE service_id=?");
			$stmt->bindValue(1, $service_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Vulnerability Exploitation
		elseif ($activity==9) {
			$stmt = $db->prepare("SELECT hack_scenario_vulnerabilities.* FROM hack_scenario_vulnerabilities JOIN hack_scenario_hosts on hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_vulnerabilities.id=? and hack_scenario_hosts.user_id=? and hack_scenario_vulnerabilities.discovered=1");
			$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$host_id=$row['host_id'];
				$vuln_name=$row['vuln_name'];
				$vuln_integrity=$row['integrity'];
				$vuln_availability=$row['availability'];
			}
			
			if ($vuln_integrity==1) {
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET exploited=1 WHERE id=?");
				$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET hacked=1 WHERE id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+10 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+10 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET exploited=2 WHERE id=?");
				$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
				$stmt->execute();
			}
			if ($vuln_availability==1) {
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET down=1 WHERE id=?");
				$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET down=1 WHERE id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Bruteforce Users and Passwords
		elseif ($activity==10) {
			$stmt = $db->prepare("SELECT hack_scenario_vulnerabilities.* FROM hack_scenario_vulnerabilities JOIN hack_scenario_hosts on hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_vulnerabilities.id=? and hack_scenario_hosts.user_id=? and hack_scenario_vulnerabilities.discovered=1");
			$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$host_id=$row['host_id'];
				$vuln_name=$row['vuln_name'];
			}
			
			$stmt = $db->prepare("SELECT * FROM hack_scenario_users WHERE user_id=? and canBruteforceUser=1");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			//No users to bruteforce password
			if ($stmt->rowCount()==0) { 
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET exploited=2, bruteforcedUser=1 WHERE host_id=? and id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $vuln_id, PDO::PARAM_INT);
				$stmt->execute(); 
			}
			//Users to bruteforce password
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET exploited=1, bruteforcedUser=1, bruteforcedPass=1 WHERE host_id=? and id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $vuln_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET hacked=1 WHERE id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_users SET bruteforcePass=1,bruteforceUser=1,visible=1 WHERE user_id=? and canBruteforceUser=1");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+10 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+10 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Bruteforce Passwords
		elseif ($activity==11) {
			$stmt = $db->prepare("SELECT hack_scenario_vulnerabilities.* FROM hack_scenario_vulnerabilities JOIN hack_scenario_hosts on hack_scenario_vulnerabilities.host_id=hack_scenario_hosts.id WHERE hack_scenario_vulnerabilities.id=? and hack_scenario_hosts.user_id=? and hack_scenario_vulnerabilities.discovered=1");
			$stmt->bindValue(1, $vuln_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$host_id=$row['host_id'];
				$vuln_name=$row['vuln_name'];
			}
			
			$stmt = $db->prepare("SELECT * FROM hack_scenario_users WHERE user_id=? and visible=1 and canBruteforcePass=1");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			//No users to bruteforce password
			if ($stmt->rowCount()==0) { 
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET exploited=2, bruteforcedPass=1 WHERE host_id=? and id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $vuln_id, PDO::PARAM_INT);
				$stmt->execute(); 
			}
			//Users to bruteforce password
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_vulnerabilities SET exploited=1, bruteforcedPass=1 WHERE host_id=? and id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $vuln_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET hacked=1 WHERE id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_users SET bruteforcePass=1 WHERE user_id=? and canBruteforcePass=1");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+10 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+10 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Discover Users
		elseif ($activity==12) {
			$stmt = $db->prepare("SELECT * FROM `hack_scenario_hosts` WHERE id=? and user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$type=$row['type'];
			}
			
			//Not Hacked
			if ($hacked==0) { 
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET user_discovered=2 WHERE id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {	
				$stmt = $db->prepare("UPDATE hack_scenario_users SET visible=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET user_discovered=1 WHERE id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Discover Connections
		elseif ($activity==13) {
			$stmt = $db->prepare("SELECT * FROM `hack_scenario_hosts` WHERE id=? and user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$type=$row['type'];
			}
			
			//Not Hacked
			if ($hacked==0) { 
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET connection_discovered=2 WHERE id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				if ($type=='dmz') {
					$stmt = $db->prepare("UPDATE hack_scenario_networks SET visible=1 WHERE type=? and user_id=?");
					$stmt->bindValue(1, "int", PDO::PARAM_INT);
					$stmt->bindValue(2, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				elseif ($type=='int') {
					$stmt = $db->prepare("UPDATE hack_scenario_networks SET visible=1 WHERE (type=? or type=?) and user_id=?");
					$stmt->bindValue(1, "client", PDO::PARAM_INT);
					$stmt->bindValue(2, "int2", PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				elseif ($type=='client') {
					$stmt = $db->prepare("UPDATE hack_scenario_networks SET visible=1 WHERE (type=? or type=?) and user_id=?");
					$stmt->bindValue(1, "int", PDO::PARAM_INT);
					$stmt->bindValue(2, "int2", PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				elseif ($type=='int2') {
					$stmt = $db->prepare("UPDATE hack_scenario_networks SET visible=1 WHERE (type=? or type=?) and user_id=?");
					$stmt->bindValue(1, "int", PDO::PARAM_INT);
					$stmt->bindValue(2, "client", PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET connection_discovered=1 WHERE id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
		}
		//Privilege Escalation
		elseif ($activity==14) {
			$stmt = $db->prepare("UPDATE hack_scenario_hosts SET escalated=1 WHERE id=? and user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		//Install Proxy
		elseif ($activity==15) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_actions.proxy FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$proxy=$row['proxy'];
			}
			
			//Not Hacked
			if ($hacked==0) { 
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to install a proxy on this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			
			//Escalated or Escalation not required
			else {			
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET proxy=1, last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "Proxy successfully installed", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET proxy=1 WHERE id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+10 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+10 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Exfiltrate Data
		elseif ($activity==16) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_hosts.contains_data,hack_scenario_actions.dataexfiltration FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$dataexfiltration=$row['dataexfiltration'];
				$contains_data=$row['contains_data'];
			}
			
			//Not Hacked
			if ($hacked==0) {
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to access data on this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET dataexfiltration=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				//No data to exfiltrate
				if ($contains_data==0) {
					$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
					$stmt->bindValue(1, "There isn't any data to exfiltrate on this host", PDO::PARAM_STR);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				else {	
					$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+5 WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+5 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					
					//Check Mission Goal
					$mission_finish=0;
					$message="Data successfully exfiltrated";
					$stmt = $db->prepare("SELECT id FROM hack_scenario_missions WHERE user_id=? and mission_type=1 and host_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->execute();
					if ($stmt->rowCount()==1) {
						$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+100,completed=1 WHERE user_id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+100 WHERE id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$stmt = $db->prepare("UPDATE user_stats SET hack_missions=hack_missions+1 WHERE id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$mission_finish=1;
						$message="Data successfully exfiltrated<br/>Congratulation! You have completed your mission!<br/>+100 Reputation!";
					}
					$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
					$stmt->bindValue(1, $message, PDO::PARAM_STR);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
			}
		}
		//Dump DB
		elseif ($activity==17) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_hosts.contains_db,hack_scenario_actions.dumpdb FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$dumpdb=$row['dumpdb'];
				$contains_db=$row['contains_db'];
			}

			//Not Hacked
			if ($hacked==0) {
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to access the database on this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET dumpdb=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				//No DB to Dump
				if ($contains_db==0) {
					$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
					$stmt->bindValue(1, "There isn't any database to dump on this host", PDO::PARAM_STR);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				else {	
					$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+5 WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+5 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					
					//Check Mission Goal
					$mission_finish=0;
					$message="Database successfully dumped";
					$stmt = $db->prepare("SELECT id FROM hack_scenario_missions WHERE user_id=? and mission_type=2 and host_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->execute();
					if ($stmt->rowCount()==1) {
						$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+100,completed=1 WHERE user_id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+100 WHERE id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$stmt = $db->prepare("UPDATE user_stats SET hack_missions=hack_missions+1 WHERE id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$mission_finish=1;
						$message="Database successfully dumped<br/>Congratulation! You have completed your mission!<br/>+100 Reputation!";
					}
					$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
					$stmt->bindValue(1, $message, PDO::PARAM_STR);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
			}
		}
		//Tamper Data
		elseif ($activity==18) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_hosts.contains_data,hack_scenario_hosts.contains_db,hack_scenario_actions.alterdata FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$alterdata=$row['alterdata'];
				$contains_data=$row['contains_data'];
				$contains_db=$row['contains_db'];
			}

			//Not Hacked
			if ($hacked==0) { 
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to access data on this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET alterdata=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				//No data to tamper
				if (($contains_db==0) and ($contains_data==0)) {
					$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
					$stmt->bindValue(1, "There isn't any data to tamper on this host", PDO::PARAM_STR);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				else {	
					$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+5 WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+5 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					
					//Check Mission Goal
					$mission_finish=0;
					$message="Data successfully tampered";
					$stmt = $db->prepare("SELECT id FROM hack_scenario_missions WHERE user_id=? and mission_type=3 and host_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->execute();
					if ($stmt->rowCount()==1) {
						$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+100,completed=1 WHERE user_id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+100 WHERE id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$stmt = $db->prepare("UPDATE user_stats SET hack_missions=hack_missions+1 WHERE id=?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();
						$mission_finish=1;
						$message="Data successfully tampered<br/>Congratulation! You have completed your mission!<br/>+100 Reputation!";
					}
					$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
					$stmt->bindValue(1, $message, PDO::PARAM_STR);
					$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
			}
		}
		//Shutdown
		elseif ($activity==19) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_actions.shutdown FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$shutdown=$row['shutdown'];
			}

			//Not Hacked
			if ($hacked==0) {
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to shutdown this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET shutdown=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_hosts SET down=1 WHERE id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+5 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+5 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				//Check Mission Goal
				$mission_finish=0;
				$message="Shutdown completed successfully";
				$stmt = $db->prepare("SELECT id FROM hack_scenario_missions WHERE user_id=? and mission_type=4 and host_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->execute();
				if ($stmt->rowCount()==1) {
					$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+100,completed=1 WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+100 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user_stats SET hack_missions=hack_missions+1 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$mission_finish=1;
					$message="Shutdown completed successfully<br/>Congratulation! You have completed your mission!<br/>+100 Reputation!";
				}
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $message, PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Ransomware
		elseif ($activity==20) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_actions.ransomware FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$ransomware=$row['ransomware'];
			}
			
			//Not Hacked
			if ($hacked==0) {
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to install a ransomware on this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET ransomware=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+5 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+5 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				//Check Mission Goal
				$mission_finish=0;
				$message="Ransomware successfully installed";
				$stmt = $db->prepare("SELECT id FROM hack_scenario_missions WHERE user_id=? and mission_type=5 and host_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->execute();
				if ($stmt->rowCount()==1) {
					$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+100,completed=1 WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+100 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user_stats SET hack_missions=hack_missions+1 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$mission_finish=1;
					$message="Ransomware successfully installed<br/>Congratulation! You have completed your mission!<br/>+100 Reputation!";
				}
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $message, PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		//Keylogger
		elseif ($activity==21) {
			$stmt = $db->prepare("SELECT hack_scenario_hosts.hacked,hack_scenario_hosts.require_escalation,hack_scenario_hosts.escalated,hack_scenario_actions.keylogger FROM hack_scenario_hosts JOIN hack_scenario_actions ON hack_scenario_hosts.id=hack_scenario_actions.host_id WHERE hack_scenario_hosts.id=? and hack_scenario_hosts.user_id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$hacked=$row['hacked'];
				$require_escalation=$row['require_escalation'];
				$escalated=$row['escalated'];
				$keylogger=$row['keylogger'];
			}
			
			//Not Hacked
			if ($hacked==0) {
				//Nada
			}
			
			//Hacked but not escalated
			elseif (($hacked==1) and ($require_escalation==1) and ($escalated==0)) {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, "You don't have enough privileges to install a keylogger on this host", PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			//Escalated or Escalation not required
			else {
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET keylogger=1 WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+5 WHERE user_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+5 WHERE id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				
				//Check Mission Goal
				$mission_finish=0;
				$message="Keylogger successfully installed";
				$stmt = $db->prepare("SELECT id FROM hack_scenario_missions WHERE user_id=? and mission_type=6 and host_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->execute();
				if ($stmt->rowCount()==1) {
					$stmt = $db->prepare("UPDATE hack_scenario_missions SET rep=rep+100,completed=1 WHERE user_id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user SET missions_rep=missions_rep+100 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user_stats SET hack_missions=hack_missions+1 WHERE id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					$mission_finish=1;
					$message="Keylogger successfully installed<br/>Congratulation! You have completed your mission!<br/>+100 Reputation!";
				}
				$stmt = $db->prepare("UPDATE hack_scenario_actions SET last_message=? WHERE host_id=? and user_id=?");
				$stmt->bindValue(1, $message, PDO::PARAM_STR);
				$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		
		$stmt = $db->prepare("UPDATE hack_scenario_activities SET completed=1 WHERE user_id=? and TIMESTAMPDIFF(SECOND,NOW(),end_time)<=0 ORDER BY end_time DESC LIMIT 1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

		$resp = "{\"status\": \"OK\",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>