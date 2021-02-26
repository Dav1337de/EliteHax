<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("SELECT user.username,user.money,user.crew,user.crew_role,crew.name FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
			$role = $row['crew_role'];
			$crew_name = $row['name'];
			$username=$row['username'];
			$money=$row['money'];
		}
		
		//Counters
		$stmt = $db->prepare('SELECT count(id) as count FROM `datacenter_attack_logs` WHERE (attacking_crew=? or datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)) and attack_status=3 and result=1 and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countWar=$row['count'];
		}	
		$stmt = $db->prepare('SELECT count(id) as count FROM crew_logs WHERE type=\'action\' and crew_id=? and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countEvents=$row['count'];
		}	
		$stmt = $db->prepare('SELECT count(id) as count FROM crew_logs WHERE type=\'tournament\' and crew_id=? and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countTournament=$row['count'];
		}	

		$resp="{\"username\": \"".$username."\",\n"
		."\"new_events\": \"".$countEvents."\",\n"
		."\"new_tournaments\": \"".$countTournament."\",\n"
		."\"new_cw\": \"".$countWar."\",\n"
		."\"money\": ".$money.",\n";

		if ($role<=2) {
			$stmt = $db->prepare("SELECT * FROM ((SELECT 'WAR' as type,crew1.name as name1,crew2.name as name2,datacenter_attack_logs.*,DATE_SUB(datacenter_attack_logs.timestamp,INTERVAL 1 HOUR) as timestamp_new FROM `datacenter_attack_logs` JOIN crew AS crew1 ON crew1.id=datacenter_attack_logs.attacking_crew JOIN datacenter ON datacenter_attack_logs.datacenter_id=datacenter.id JOIN crew AS crew2 ON datacenter.crew_id=crew2.id WHERE (attacking_crew=? or datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)) and attack_status=3 and result=1 order by timestamp desc LIMIT 50) UNION (SELECT 'DETAILS' as type, type as name1,target as name2,'' as id,(SELECT username from user where id=user_id) as attacking_crew,(SELECT crew.name FROM crew JOIN datacenter ON datacenter.crew_id=crew.id WHERE datacenter.id=target2) as datacenter_id,'' as attack_type,'' as result,'' as anon,'' as attack_status,id as mf_hack,'' as cc_reward,'' as money_reward,'' as region,timestamp,DATE_SUB(timestamp,INTERVAL 1 HOUR) as timestamp_new FROM crew_wars_logs WHERE crew=? order by timestamp DESC LIMIT 100)) as t ORDER BY timestamp DESC"); 
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
			$stmt->bindValue(3, $crew_id, PDO::PARAM_INT);
			$stmt->execute();
		}
		else {
			$stmt = $db->prepare("SELECT 'WAR' as type,crew1.name as name1,crew2.name as name2,datacenter_attack_logs.*,DATE_SUB(datacenter_attack_logs.timestamp,INTERVAL 1 HOUR) as timestamp_new FROM `datacenter_attack_logs` JOIN crew AS crew1 ON crew1.id=datacenter_attack_logs.attacking_crew JOIN datacenter ON datacenter_attack_logs.datacenter_id=datacenter.id JOIN crew AS crew2 ON datacenter.crew_id=crew2.id WHERE (attacking_crew=? or datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)) and attack_status=3 and result=1 order by timestamp desc LIMIT 50"); 
			$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
			$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
			$stmt->execute();
		}

		$resp = $resp."\"crew_wars\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['type']=="WAR") {
				$anon=$row['anon'];
				$attack_type=$row['attack_type'];
				$mf_hack=$row['mf_hack'];
				$region=$row['region'];
				$cc_reward=$row['cc_reward'];
				$money_reward=$row['money_reward'];
				$timestamp=$row['timestamp_new'];
				if ($row['attacking_crew']==$crew_id) {
					$type="attack";
					$attacking_crew=0;
					$target_crew=$row['name2'];
				}
				else {
					$type="defend";
					if ($anon==0) {
						$attacking_crew=$row['name1'];
					}
					else {
						$cc_reward=0;
						$region=0;
						$attacking_crew=0;
					}
					$target_crew=0;
				}
				$resp = $resp."{\n"
				."\"log_type\": \"WAR\",\n"
				."\"type\": \"".$type."\",\n"
				."\"attack_type\": \"".$attack_type."\",\n"
				."\"anon\": ".$anon.",\n"
				."\"region\": ".$region.",\n"
				."\"attacking_crew\": \"".$attacking_crew."\",\n"
				."\"target_crew\": \"".$target_crew."\",\n"
				."\"mf_hack\": \"".$mf_hack."\",\n"
				."\"cc_reward\": \"".$cc_reward."\",\n"
				."\"money_reward\": \"".$money_reward."\",\n"
				."\"timestamp\": \"".$timestamp."\"},";
			}
			elseif ($row['type']=="DETAILS") {
				$resp = $resp."{\n"
				."\"log_type\": \"DETAILS\",\n"
				."\"type\": \"".$row['name1']."\",\n"
				."\"attack_type\": \"".$row['name2']."\",\n"
				."\"anon\": 0,\n"
				."\"region\": 0,\n"
				."\"attacking_crew\": \"".$row['attacking_crew']."\",\n"
				."\"target_crew\": \"".$row['datacenter_id']."\",\n"
				."\"mf_hack\": \"\",\n"
				."\"cc_reward\": \"\",\n"
				."\"money_reward\": \"\",\n"
				."\"timestamp\": \"".$row['timestamp_new']."\"},";
			}
		}
		$resp = $resp."]}";
		//echo $resp;
		echo base64_encode($resp);		
		
		$stmt = $db->prepare("UPDATE user SET crew_log_timestamp=NOW() WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>