<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT missions_available.id,missions.difficult,missions_available.duration,missions_available.reward,missions_available.xp,missions.target_name,missions.description,missions_available.running,missions_available.time_finish,user.username, user.money, mission_center.lvl, mission_center.upgrade_lvl,TIMESTAMPDIFF(SECOND,NOW(),missions_available.time_finish) as m_interval FROM missions_available JOIN missions ON missions_available.type=missions.type and missions_available.subtype=missions.subtype and missions_available.difficult = missions.difficult JOIN user ON missions_available.user_id=user.id JOIN mission_center ON user.id = mission_center.user_id WHERE missions_available.user_id=? order by missions_available.running DESC");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		$resp = "{\n\"available_missions\":[\n";
		foreach ($arr as $row) {
			$resp=$resp."{\"mission_id\": ".$row['id'].",\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"money\": \"".$row['money']."\",\n"
			."\"mc_lvl\": ".$row['lvl'].",\n"
			."\"mc_upgrade_lvl\": ".$row['upgrade_lvl'].",\n"
			."\"running\": ".$row['running'].",\n"
			."\"difficult\": ".$row['difficult'].",\n"
			."\"duration\": ".$row['duration'].",\n"
			."\"reward\": ".$row['reward'].",\n"
			."\"xp\": ".$row['xp'].",\n"
			."\"mission_name\": \"".$row['target_name']."\",\n"
			."\"mission_desc\": \"".$row['description']."\",\n";
			if ($row['running'] == 1) {
				$interval = $row['m_interval'];
				$resp = $resp."\"time_finish\": ".$interval.",\n";
			} else { $resp = $resp."\"time_finish\": 0,\n"; }
			$resp=$resp."},";
		}
		$resp = $resp."],\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>