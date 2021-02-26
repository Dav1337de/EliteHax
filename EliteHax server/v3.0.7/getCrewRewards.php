<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("SELECT user.username,user.money,user.crew,crew.name FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
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

		$stmt = $db->prepare("SELECT type,subtype,field1,field2,field3,DATE_SUB(timestamp,INTERVAL 1 HOUR) as timestamp FROM crew_logs WHERE crew_id=? and type='tournament' ORDER BY timestamp DESC LIMIT 50"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->execute();

		$resp = $resp."\"crew_rewards\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp."{\"type\": \"".$row['type']."\",\n"
			."\"subtype\": \"".$row['subtype']."\",\n"
			."\"field1\": \"".$row['field1']."\",\n"
			."\"field2\": \"".$row['field2']."\",\n"
			."\"field3\": \"".$row['field3']."\",\n"
			."\"timestamp\": \"".$row['timestamp']."\"},";
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