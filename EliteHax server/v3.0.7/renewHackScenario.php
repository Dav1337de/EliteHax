<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	
	//Init arrays
	$hosts = [];
	
	$dmzHosts = [];
	$dmzHostsH = [];
	$dmzHostsC=0;
	$dmzVulnC=0;
	$dmzHostPos=0;
	
	$intHosts = [];
	$intHostsH = [];
	$intHostsC=0;
	$intVulnC=0;

	$clientHosts = [];
	$clientHostsH = [];
	$clientHostsC=0;
	$clientVulnC=0;
	
	$int2Hosts = [];
	$int2HostsH = [];
	$int2HostsC=0;
	$int2VulnC=0;
	
	$users = [];
	$usersC = 0;
	
	function generateUser($db,$id,$type,$host_id) {
		//Admin
		if ($type==2) {
			$rndGenerate=random_int(0,1);
		}
		if (($type==1) or ($rndGenerate==1)) {
			//Social
			$social=0;
			$socialChance=10;
			if ((100-random_int(1,100))<$socialChance) {
				$social=1;
			}
			//Bruteforce User
			$bruteforceU=0;
			$bruteforceUChance=10;
			if ((100-random_int(1,100))<$bruteforceUChance) {
				$bruteforceU=1;
			}
			//Bruteforce Pass
			$bruteforce=0;
			$bruteforceChance=25;
			if ((100-random_int(1,100))<$bruteforceChance) {
				$bruteforce=1;
			}
			if ($bruteforceU==1) {
				$bruteforce=1;
			}
			$stmt = $db->prepare("INSERT INTO hack_scenario_users (user_id, host_id, firstname, lastname, role, canSocial, canBruteforceUser, canBruteforcePass, social, bruteforceUser, bruteforcePass) VALUES (?,?,(SELECT firstname FROM `hack_scenario_firstnames` order by rand() limit 1),(SELECT lastname FROM `hack_scenario_lastnames` order by rand() limit 1),?,?,?,?,0,0,0)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $host_id, PDO::PARAM_STR);
			$stmt->bindValue(3, $type, PDO::PARAM_STR);
			$stmt->bindValue(4, $social, PDO::PARAM_STR);
			$stmt->bindValue(5, $bruteforceU, PDO::PARAM_INT);
			$stmt->bindValue(6, $bruteforce, PDO::PARAM_INT);
			$stmt->execute();
		}
	}
	
	function generateVulnerability($db,$host_id,$service_id,$type) {
		if (random_int(0,2)>0) {
			$stmt = $db->prepare("SELECT service_name,login,web FROM hack_scenario_services WHERE host_id=? and id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $service_id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
				$service_name=$row['service_name'];
				$service_login=$row['login'];
				$service_web=$row['web'];
			}	
			
			$vulnNames=array("Remote Code Execution","Default Password","Buffer Overflow","Heap Overflow","Authentication Bypass","Denial Of Service","Memory Corruption","Use-After-Free","Denial Of Service","Memory Corruption","Integer Overflow","Authentication Found");
			$vulnSeverities=array("C","C","H","H","H","H","H","M","M","M","M","L");
			$vulnExploitC=array(100,100,90,90,90,0,70,80,70,80,70,0);
			$vuln=random_int(0,11);
			
			//Login vulnerabilities only on login services
			$added=0;
			while ($added==0) {
				if ($service_login==1) { $added=1; }
				else {
					if (($vuln==1) or ($vuln==4) or ($vuln==11)) {
						$vuln=random_int(0,10);
					}
					else {
						$added=1;
					}
				}
			}
			
			$vulnName=$vulnNames[$vuln];
			$vulnSeverity=$vulnSeverities[$vuln];
			$vulnExploitChance=$vulnExploitC[$vuln];
			
			if ($vuln<=1) {
				$vulnIntegrity=1;
				$vulnAvail=0;
			}
			if ((($vuln>=2) and ($vuln<=3)) or (($vuln>=5) and ($vuln<=6)) or (($vuln>=8) and ($vuln<=9))) {
				if ((100-random_int(1,100))<$vulnExploitChance) {
					$vulnIntegrity=1;
					$vulnAvail=0;
				}
				else {
					$vulnIntegrity=0;
					$vulnAvail=1;
				}
			}
			elseif (($vuln==4) or ($vuln==7)) {
				if ((100-random_int(1,100))<$vulnExploitChance) {
					$vulnIntegrity=1;
				}
				else {
					$vulnIntegrity=0;
				}
				$vulnAvail=0;
			}
			elseif ($vuln==10) {
				$vulnIntegrity=0;
				$vulnAvail=1;
			}
			elseif ($vuln==11) {
				$vulnIntegrity=0;
				$vulnAvail=0;
			}
			
			$stmt = $db->prepare("INSERT INTO hack_scenario_vulnerabilities (host_id,service_id,vuln_name,vuln_severity,integrity,availability) VALUES (?,?,CONCAT((select service_name from hack_scenario_services where id=?),' ',?),?,?,?)");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $service_id, PDO::PARAM_INT);
			$stmt->bindValue(3, $service_id, PDO::PARAM_INT);
			$stmt->bindValue(4, $vulnName, PDO::PARAM_STR);
			$stmt->bindValue(5, $vulnSeverity, PDO::PARAM_STR);
			$stmt->bindValue(6, $vulnIntegrity, PDO::PARAM_INT);
			$stmt->bindValue(7, $vulnAvail, PDO::PARAM_INT);
			$stmt->execute();
			
			if (($type=='dmza') and ($vulnIntegrity==1)) { $dmzVulnC++; }
			elseif (($type=='inta') and ($vulnIntegrity==1)) { $intVulnC++; }
			elseif (($type=='clienta') and ($vulnIntegrity==1)) { $clientVulnC++; }
			elseif (($type=='inta2') and ($vulnIntegrity==1)) { $int2VulnC++; }
		}
	}
	
	function generateInfoVulnerability($db,$host_id,$service_id) {
		$vulnName="Services is running";
		$vulnSeverity="I";
		$vulnIntegrity=0;
		$vulnAvail=0;
		$stmt = $db->prepare("INSERT INTO hack_scenario_vulnerabilities (host_id,service_id,vuln_name,vuln_severity,integrity,availability) VALUES (?,?,CONCAT((select service_name from hack_scenario_services where id=?),' ',?),?,?,?)");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $service_id, PDO::PARAM_INT);
		$stmt->bindValue(3, $service_id, PDO::PARAM_INT);
		$stmt->bindValue(4, $vulnName, PDO::PARAM_STR);
		$stmt->bindValue(5, $vulnSeverity, PDO::PARAM_STR);
		$stmt->bindValue(6, $vulnIntegrity, PDO::PARAM_INT);
		$stmt->bindValue(7, $vulnAvail, PDO::PARAM_INT);
		$stmt->execute();
	}
	
	function generateStdService($db,$host_id,$type) {
		$db->beginTransaction();
		$stmt = $db->prepare("INSERT INTO hack_scenario_services (host_id,service_port,service_name,login,web) SELECT ?,port,name,login,web FROM `hack_scenario_service_name` WHERE {$type}=1 and port not in (SELECT service_port FROM hack_scenario_services WHERE host_id=?) order by rand() limit 1");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		$sid=$db->lastInsertId();
		$db->commit();
		generateVulnerability($db,$host_id,$sid,$type);
		generateInfoVulnerability($db,$host_id,$sid);
	}
	
	function generateRndService($db,$host_id,$type) {
		$db->beginTransaction();
		$stmt = $db->prepare("INSERT INTO hack_scenario_services (host_id,service_port,service_name,login,web) SELECT ?,CONCAT(ROUND((RAND() * (65534-1024))+1024),'/TCP'),name,login,web FROM `hack_scenario_service_name` WHERE {$type}=1 and name not in (SELECT service_name FROM hack_scenario_services WHERE host_id=?) order by rand() limit 1");
		$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
		$sid=$db->lastInsertId();
		$db->commit();
		generateVulnerability($db,$host_id,$sid,$type);
		generateInfoVulnerability($db,$host_id,$sid);		
	}
	
	function initHostActions($db,$host_id,$id) {
		$stmt = $db->prepare("INSERT INTO hack_scenario_actions (user_id,host_id) VALUES (?,?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->execute();
	}
	
	function generateDmzHost($db,$id,$j) {
		global $dmzHostsC;
		global $dmzHostPos;
		$dmzHostnames = array("web","dmz","srv","ext","host");
		$generateHost = random_int(0,1);
		if ($generateHost==1) {
			$escalation=0;
			$escalationChance=50;
			if ((100-random_int(1,100))<$escalationChance) {
				$escalation=1;
			}
			$dmzHost[$j]=1;
			$dmzHostPos=$j;
			$dmzHostsC++;
			$dmzHostH[$j] = $dmzHostnames[random_int(0,4)]."-".str_pad(random_int(0,99999),5,0,STR_PAD_LEFT);
			$db->beginTransaction();
			$stmt = $db->prepare("INSERT INTO hack_scenario_hosts (user_id, hostname, type, pos, os, require_escalation, timestamp) VALUES (?,?,?,?,?,?,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $dmzHostH[$j], PDO::PARAM_STR);
			$stmt->bindValue(3, "dmz", PDO::PARAM_STR);
			$stmt->bindValue(4, $j, PDO::PARAM_INT);
			$stmt->bindValue(5, random_int(1,3), PDO::PARAM_INT);
			$stmt->bindValue(6, $escalation, PDO::PARAM_INT);
			$stmt->execute();
			$host_id=$db->lastInsertId();
			$db->commit();
			initHostActions($db,$host_id,$id);
			
			//Generate Services
			$stdServices = random_int(1,4);
			for ($k=1;$k<=$stdServices;$k++) {
				generateStdService($db,$host_id,'dmza');
			}
			$rndServices = random_int(0,3);
			for ($k=1;$k<=$rndServices;$k++) {
				generateRndService($db,$host_id,'dmza');
			}
		}
	}
	
	function generateIntHost($db,$id,$j) {
		global $intHostsC;
		$intHostnames = array("app","int","srv","host","eh","elitehax");
		$generateHost = random_int(0,1);
		if ($generateHost==1) {
			$escalation=0;
			$escalationChance=50;
			if ((100-random_int(1,100))<$escalationChance) {
				$escalation=1;
			}
			$intHost[$j]=1;
			$intHostsC++;
			$intHostH[$j] = $intHostnames[random_int(0,5)]."-".str_pad(random_int(0,99999),5,0,STR_PAD_LEFT);
			$db->beginTransaction();
			$stmt = $db->prepare("INSERT INTO hack_scenario_hosts (user_id, hostname, type, pos, os, require_escalation, timestamp) VALUES (?,?,?,?,?,?,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $intHostH[$j], PDO::PARAM_STR);
			$stmt->bindValue(3, "int", PDO::PARAM_STR);
			$stmt->bindValue(4, $j, PDO::PARAM_INT);
			$stmt->bindValue(5, random_int(1,3), PDO::PARAM_INT);
			$stmt->bindValue(6, $escalation, PDO::PARAM_INT);
			$stmt->execute();	
			$host_id=$db->lastInsertId();
			$db->commit();
			initHostActions($db,$host_id,$id);
			
			//Generate Services
			$stdServices = random_int(1,4);
			for ($k=1;$k<=$stdServices;$k++) {
				generateStdService($db,$host_id,'inta');
			}
			$rndServices = random_int(0,3);
			for ($k=1;$k<=$rndServices;$k++) {
				generateRndService($db,$host_id,'inta');
			}
			//Generate Admin User
			generateUser($db,$id,2,$host_id);
		}
	}
	
	function generateClientHost($db,$id,$j) {
		global $clientHostsC;
		$clientHostnames = array("desktop","client","workstation","host","eh","elitehax");
		$generateHost = random_int(0,1);
		if ($generateHost==1) {
			$escalation=0;
			$escalationChance=30;
			if ((100-random_int(1,100))<$escalationChance) {
				$escalation=1;
			}
			$clientHost[$j]=1;
			$clientHostsC++;
			$clientHostH[$j] = $clientHostnames[random_int(0,5)]."-".str_pad(random_int(0,99999),5,0,STR_PAD_LEFT);
			$db->beginTransaction();
			$stmt = $db->prepare("INSERT INTO hack_scenario_hosts (user_id, hostname, type, pos, os, require_escalation, timestamp) VALUES (?,?,?,?,?,?,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $clientHostH[$j], PDO::PARAM_STR);
			$stmt->bindValue(3, "client", PDO::PARAM_STR);
			$stmt->bindValue(4, $j, PDO::PARAM_INT);
			$stmt->bindValue(5, random_int(1,3), PDO::PARAM_INT);
			$stmt->bindValue(6, $escalation, PDO::PARAM_INT);
			$stmt->execute();	
			$host_id=$db->lastInsertId();
			$db->commit();
			initHostActions($db,$host_id,$id);
			
			//Generate Services
			$stdServices = random_int(1,4);
			for ($k=1;$k<=$stdServices;$k++) {
				generateStdService($db,$host_id,'clienta');
			}
			$rndServices = random_int(0,3);
			for ($k=1;$k<=$rndServices;$k++) {
				generateRndService($db,$host_id,'clienta');
			}
			
			//Generate Normal User
			generateUser($db,$id,1,$host_id);
		}
	}
	
	function generateInt2Host($db,$id,$j) {
		global $int2HostsC;
		$int2Hostnames = array("db","int","srv","host","eh","elitehax");
		$generateHost = random_int(0,1);
		if ($generateHost==1) {
			$escalation=0;
			$escalationChance=40;
			if ((100-random_int(1,100))<$escalationChance) {
				$escalation=1;
			}
			$int2Host[$j]=1;
			$int2HostsC++;
			$int2HostH[$j] = $int2Hostnames[random_int(0,5)]."-".str_pad(random_int(0,99999),5,0,STR_PAD_LEFT);
			$db->beginTransaction();
			$stmt = $db->prepare("INSERT INTO hack_scenario_hosts (user_id, hostname, type, pos, os, require_escalation, timestamp) VALUES (?,?,?,?,?,?,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $int2HostH[$j], PDO::PARAM_STR);
			$stmt->bindValue(3, "int2", PDO::PARAM_STR);
			$stmt->bindValue(4, $j, PDO::PARAM_INT);
			$stmt->bindValue(5, random_int(1,4), PDO::PARAM_INT);
			$stmt->bindValue(6, $escalation, PDO::PARAM_INT);
			$stmt->execute();
			$host_id=$db->lastInsertId();
			$db->commit();
			initHostActions($db,$host_id,$id);
			
			//Generate Services
			$stdServices = random_int(1,4);
			for ($k=1;$k<=$stdServices;$k++) {
				generateStdService($db,$host_id,'inta2');
			}
			$rndServices = random_int(0,3);
			for ($k=1;$k<=$rndServices;$k++) {
				generateRndService($db,$host_id,'inta2');
			}
			//Generate Random User
			generateUser($db,$id,random_int(1,2),$host_id);
		}
	}
	
	function generateMissionGoal($db,$id) {
		//Choose random mission
		$stmt = $db->prepare("SELECT * FROM hack_scenario_mission order by rand() limit 1");
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$type=$row['type'];
			$desc=$row['description'];
		}	
		//Target network zones
		if (($type==1) or ($type==3) or ($type==5) or ($type==6)) {
			$target1='client';
			$target2='int2';
		}
		elseif ($type==2) {
			$target1='int2';
			$target2='int2';
		}
		elseif ($type==4) {
			$target1='int1';
			$target2='int2';
		}
		//Select target host
		$stmt = $db->prepare("SELECT id,hostname FROM `hack_scenario_hosts` WHERE user_id=? and (type=? or type=?) order by rand() limit 1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $target1, PDO::PARAM_STR);
		$stmt->bindValue(3, $target2, PDO::PARAM_STR);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$host_id=$row['id'];
			$hostname=$row['hostname'];
		}
		$complete_desc=$desc."".$hostname;

		//Insert Mission Goal
		$stmt = $db->prepare("INSERT INTO hack_scenario_missions (user_id, host_id, mission_type, description, completed, start_time, end_time) VALUES (?,?,?,?,0,NOW(),DATE_ADD(NOW(),INTERVAL 2 DAY))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $host_id, PDO::PARAM_INT);
		$stmt->bindValue(3, $type, PDO::PARAM_INT);
		$stmt->bindValue(4, $complete_desc, PDO::PARAM_STR);
		$stmt->execute();
		if ($type==1) {
			$stmt = $db->prepare("UPDATE `hack_scenario_hosts` SET contains_data=1 WHERE id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		elseif ($type==2) {
			$stmt = $db->prepare("UPDATE `hack_scenario_hosts` SET contains_db=1 WHERE id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		elseif ($type==3) {
			$stmt = $db->prepare("UPDATE `hack_scenario_hosts` SET contains_data=1,contains_db=1 WHERE id=?");
			$stmt->bindValue(1, $host_id, PDO::PARAM_INT);
			$stmt->execute();
		}
	}
	
	function checkMissionComletability($db,$id) {
		$canComplete=0;
		//Select target host and network
		$stmt = $db->prepare("SELECT hack_scenario_missions.host_id, hack_scenario_hosts.type FROM `hack_scenario_missions` JOIN hack_scenario_hosts ON hack_scenario_missions.host_id=hack_scenario_hosts.id WHERE hack_scenario_missions.user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
			$target_host=$row['host_id'];
			$target_zone=$row['type'];
			if ($target_zone=="int2") { $target_zone_name="inta2"; }
			else { $target_zone_name=$target_zone."a"; }
		}
		
		//Target Host Exploitability
		$canExploitHost=0;
		while ($canExploitHost==0) {
			$stmt = $db->prepare("SELECT * FROM `hack_scenario_vulnerabilities` where host_id=? and integrity=1 and availability=0");
			$stmt->bindValue(1, $target_host, PDO::PARAM_INT);
			$stmt->execute();
			if ($stmt->rowCount()>0) { $canExploitHost=1; }
			else { generateRndService($db,$target_host,$target_zone_name); }
		}
		
		//Path to Host Exploitability - Exploitation
		//DMZ zone Exploitability
		$canExploitDMZ=0;
		while ($canExploitDMZ==0) {
			$stmt = $db->prepare("SELECT * FROM `hack_scenario_vulnerabilities` WHERE host_id in (SELECT id FROM `hack_scenario_hosts` where user_id=? and type='dmz') and integrity=1 and availability=0");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			if ($stmt->rowCount()>0) { $canExploitDMZ=1; }
			else { 
				//Add a random service to a random host in the dmz zone
				$stmt = $db->prepare("SELECT id FROM `hack_scenario_hosts` where user_id=? and type='dmz' order by rand() limit 1");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
					$dmz_host=$row['id'];
					generateRndService($db,$dmz_host,'dmza');
				}
			}
		}
		
		//Int zone exploitability
		if (($target_zone=="client") or ($target_zone=="int2")) {
			$canExploitInt=0;
			while ($canExploitInt==0) {
				$stmt = $db->prepare("SELECT * FROM `hack_scenario_vulnerabilities` WHERE host_id in (SELECT id FROM `hack_scenario_hosts` where user_id=? and type='int') and integrity=1 and availability=0");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				if ($stmt->rowCount()>0) { $canExploitInt=1; }
				else { 
					//Add a random service to a random host in the int zone
					$stmt = $db->prepare("SELECT id FROM `hack_scenario_hosts` where user_id=? and type='int' order by rand() limit 1");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {			
						$int_host=$row['id'];
						generateRndService($db,$int_host,'inta');
					}
				}
			}
		}
	}
	
	try {
		$id = getIdFromToken($db);
		
		//Remove Previous Scenario
		$stmt = $db->prepare("DELETE FROM hack_scenario_networks WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("DELETE FROM hack_scenario_hosts WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("UPDATE hack_scenario_activities SET end_time=NOW(),completed=1 WHERE user_id=? and TIMESTAMPDIFF(SECOND,NOW(),end_time)>0");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Generate Networks
		$stmt = $db->prepare("INSERT INTO hack_scenario_networks (user_id, type, name) VALUES (?,?,?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, "dmz", PDO::PARAM_STR);
		$stmt->bindValue(3, "DMZ Network", PDO::PARAM_STR);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO hack_scenario_networks (user_id, type, name) VALUES (?,?,?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, "int", PDO::PARAM_STR);
		$stmt->bindValue(3, "Internal Network", PDO::PARAM_STR);
		$stmt->execute();	
		$stmt = $db->prepare("INSERT INTO hack_scenario_networks (user_id, type, name) VALUES (?,?,?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, "client", PDO::PARAM_STR);
		$stmt->bindValue(3, "Client Network", PDO::PARAM_STR);
		$stmt->execute();	
		$stmt = $db->prepare("INSERT INTO hack_scenario_networks (user_id, type, name) VALUES (?,?,?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, "int2", PDO::PARAM_STR);
		$stmt->bindValue(3, "Production Network", PDO::PARAM_STR);
		$stmt->execute();	
		
		//Generate DMZ Hosts
		for ($i=1;$i<=3;$i++) {
			generateDmzHost($db,$id,$i);
		}
		while ($dmzHostsC<2) { 
			if ($dmzHostPos==1) {
				generateDmzHost($db,$id,random_int(2,3)); 
			}
			else {
				generateDmzHost($db,$id,1); 
			}
		}
	
		//Generate Int Hosts
		for ($i=1;$i<=3;$i++) {
			generateIntHost($db,$id,$i);
		}
		while ($intHostsC==0) { generateIntHost($db,$id,random_int(1,3)); }
		
		//Generate Client Hosts
		for ($i=1;$i<=3;$i++) {
			generateClientHost($db,$id,$i);
		}
		while ($clientHostsC==0) { generateClientHost($db,$id,random_int(1,3)); }
		
		//Generate Int2 Hosts
		for ($i=1;$i<=3;$i++) {
			generateInt2Host($db,$id,$i);
		}
		while ($int2HostsC==0) { generateInt2Host($db,$id,random_int(1,3)); }
		
		//Generate Mission Goal
		generateMissionGoal($db,$id);
		
		checkMissionComletability($db,$id);
		
		$stmt = $db->prepare('SELECT username,money FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n\"status\": \"OK\"\n}";			
		}		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>