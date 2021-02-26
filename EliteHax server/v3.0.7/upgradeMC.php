<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	try {
		$id = getIdFromToken($db);
		
		//Running missions & Mission Center Lvl
		$stmt = $db->prepare("SELECT mission_center.*,user.money FROM `mission_center` JOIN user ON mission_center.user_id = user.id WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$mc_upgrade_lvl = $row['upgrade_lvl'];
			$mc_lvl = $row['lvl'];
			$money = $row['money'];
		}
		if ($mc_lvl == 5) { exit(); }
		if ($money < mc_upgrade_cost($mc_lvl)) {  
			$resp = "{\n\"STATUS\": \"NO_MONEY\"\n}";
			exit(base64_encode($resp));
		}
		$new_money = $money - mc_upgrade_cost($mc_lvl);
		if ($mc_upgrade_lvl < 99) {
			$stmt = $db->prepare("UPDATE mission_center SET upgrade_lvl=upgrade_lvl+1 WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("UPDATE user SET money=? WHERE id=?");
			$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$resp = "{\n\"STATUS\": \"OK\",\n\"new_money\": ".$new_money.",\n\"mc_upgrade_lvl\": ".($mc_upgrade_lvl+1)."\n}";
		}
		else {
			$stmt = $db->prepare("UPDATE mission_center SET upgrade_lvl=0,lvl=lvl+1 WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("UPDATE user SET money=? WHERE id=?");
			$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$resp = "{\n\"STATUS\": \"OK_NEW_LVL\",\n\"new_money\": ".$new_money.",\n\"mc_upgrade_lvl\": 0,\n\"new_lvl\": ".($mc_lvl+1)."\n}";
		}

		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>