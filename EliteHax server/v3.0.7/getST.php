<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT skill_tree.*,user.username,user.money FROM user JOIN skill_tree ON user.id=skill_tree.user_id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$money = $row['money'];
			$username = $row['username'];
			$skill_points = $row['skill_points'];
			$st_hourly = $row['st_hourly'];
			$st_dev1 = $row['st_dev1'];
			$st_analyst = $row['st_analyst'];
			$st_mission_speed = $row['st_mission_speed'];
			$st_safe_pay = $row['st_safe_pay'];
			$st_upgrade_speed = $row['st_upgrade_speed'];
			$st_dev2 = $row['st_dev2'];
			$st_pentester = $row['st_pentester'];
			$st_stealth = $row['st_stealth'];
			$st_mission_reward = $row['st_mission_reward'];
			$st_bank_exp = $row['st_bank_exp'];
			$st_upgrade_cost = $row['st_upgrade_cost'];
			$st_pentester2 = $row['st_pentester2'];
		}	
		
		$resp = "{\n\"status\": \"OK\",\n"
				."\"username\": \"".$username."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"skill_points\": \"".$skill_points."\",\n"
				."\"st_hourly\": ".$st_hourly.",\n"
				."\"st_dev1\": ".$st_dev1.",\n"
				."\"st_analyst\": ".$st_analyst.",\n"
				."\"st_mission_speed\": ".$st_mission_speed.",\n"
				."\"st_safe_pay\": ".$st_safe_pay.",\n"
				."\"st_upgrade_speed\": ".$st_upgrade_speed.",\n"
				."\"st_dev2\": ".$st_dev2.",\n"
				."\"st_pentester\": ".$st_pentester.",\n"
				."\"st_stealth\": ".$st_stealth.",\n"
				."\"st_mission_reward\": ".$st_mission_reward.",\n"
				."\"st_bank_exp\": ".$st_bank_exp.",\n"
				."\"st_upgrade_cost\": ".$st_upgrade_cost.",\n"
				."\"st_pentester2\": ".$st_pentester2.",\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>