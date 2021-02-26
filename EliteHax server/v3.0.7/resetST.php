<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT skill_tree_reset,lvl FROM items JOIN skill_tree ON items.user_id=skill_tree.user_id WHERE items.user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$st_reset = $row['skill_tree_reset'];
			$skill_points = $row['lvl']-1;
		}
		if ($st_reset<1) { exit(); }
		else {
			$stmt = $db->prepare('UPDATE skill_tree SET skill_points=?, st_hourly=0, st_dev1=0, st_analyst=0, st_mission_speed=0, st_safe_pay=0, st_upgrade_speed=0, st_dev2=0, st_pentester=0, st_stealth=0, st_mission_reward=0, st_bank_exp=0, st_upgrade_cost=0, st_pentester2=0 WHERE user_id=?');
			$stmt->bindValue(1, $skill_points, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare('UPDATE items SET skill_tree_reset=skill_tree_reset-1 WHERE user_id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
		}
		$resp = "{\"status\": \"OK\",\n"
		."\"skill_points\": ".$skill_points.",\n"
		."\"st_reset\": ".($st_reset-1)."\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>