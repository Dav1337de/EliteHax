<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['type']))
		exit("");
	$type = $_POST['type'];
	$whitelist = Array( 'st_hourly', 'st_dev1', 'st_analyst', 'st_mission_speed', 'st_safe_pay', 'st_upgrade_speed', 'st_dev2', 'st_pentester', 'st_stealth', 'st_mission_reward', 'st_bank_exp', 'st_upgrade_cost', 'st_pentester2' );
	if( !in_array( $type, $whitelist ) )
		exit("");
	try {
		$id = getIdFromToken($db);
		$db->beginTransaction();
		$stmt = $db->prepare("SELECT skill_tree.*,user.username,user.money FROM user JOIN skill_tree ON user.id=skill_tree.user_id WHERE user.id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			//Check Skill Points
			if ($row['skill_points'] < 1) { exit(""); }
		
			//Check Previous Skills
			if (($type == "st_pentester2") and (($row['st_bank_exp'] == 0) or ($row['st_pentester']!=5))) { exit(""); }
			if (($type == "st_dev2") and (($row['st_safe_pay'] == 0) or ($row['st_dev1']!=5))) { exit(""); }
			if (($type == "st_bank_exp") and ($row['st_stealth'] == 0)) { exit(""); }
			if (($type == "st_upgrade_cost") and ($row['st_mission_reward'] == 0)) { exit(""); }
			if (($type == "st_upgrade_speed") and ($row['st_mission_speed'] == 0)) { exit(""); }
			if (($type == "st_safe_pay") and ($row['st_analyst'] == 0)) { exit(""); }
			if (($type == "st_stealth") and ($row['st_pentester'] == 0)) { exit(""); }
			if (($type == "st_mission_reward") and ($row['st_pentester'] == 0)) { exit(""); }
			if (($type == "st_mission_speed") and ($row['st_dev1'] == 0)) { exit(""); }
			if (($type == "st_analyst") and ($row['st_dev1'] == 0)) { exit(""); }
			if (($type == "st_pentester") and ($row['st_hourly'] == 0)) { exit(""); }
			if (($type == "st_dev1") and ($row['st_hourly'] == 0)) { exit(""); }
			
			$cur_lvl = $row[$type];
			$new_lvl = $row[$type]+1;
			
			//CHECK UPPER LIMIT
			if ($cur_lvl == 5) {
				$resp = "{\n\"status\": \"MAX_LVL\"\n}";
				exit(base64_encode($resp));		
			}
			
			//UPDATE SKILL TREE
			$stmt = $db->prepare("UPDATE skill_tree SET {$type}={$type}+1,skill_points=skill_points-1 where user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		$db->commit();
		
		$resp = "{\n"
			."\"status\": \"OK\",\n"
			."\"new_lvl\": ".($new_lvl)."\n}";
		
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>
