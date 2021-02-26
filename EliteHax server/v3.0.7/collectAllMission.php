<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
		
	try {
		$id = getIdFromToken($db);
				
		$stmt = $db->prepare("SELECT missions_available.id as mid,missions_available.reward,user.money,missions_available.xp as mxp, skill_tree.lvl, skill_tree.xp as xp FROM `missions_available` JOIN user ON missions_available.user_id=user.id JOIN skill_tree ON user.id=skill_tree.user_id WHERE missions_available.user_id=? and (NOW()-time_finish)>0 and running=1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			$resp = "{\n\"STATUS\": \"NC\"\n}";
			exit(base64_encode($resp));	
		}
		
		$new_money=0;
		$new_xp=0;
		
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$mid = $row['mid'];
			$money = $row['money'];
			$reward = $row['reward'];
			$new_money=$new_money+$reward;
			//XP
			$new_xp = $new_xp+$row['mxp'];
			$old_xp = $row['xp'];
			$clvl = $row['lvl'];
			
			$stmt = $db->prepare("UPDATE user_stats SET missions=missions+1 WHERE id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();

			$stmt = $db->prepare("UPDATE economy SET missions=missions+?, income=income+? where user_id=?");
			$stmt->bindValue(1, $reward, PDO::PARAM_INT);
			$stmt->bindValue(2, $reward, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();

			$stmt = $db->prepare("DELETE FROM missions_available WHERE id=?");
			$stmt->bindValue(1, $mid, PDO::PARAM_INT);
			$stmt->execute();			
		}
		
		//XP, LVL, Skill Tree
		$tot_xp=$old_xp+$new_xp;
		$lvl=$clvl+1;
		$new_lvl=0;
		$finished=false;
		$new_base=sommatoria($clvl);
		while (($lvl<=65) and ($finished==false)) {
			$sum=sommatoria($lvl);
			if ($sum > $tot_xp) { $finished=true; }
			else { $lvl++; $new_lvl++; $new_base=$sum; }
		}	
		
		$stmt = $db->prepare("UPDATE skill_tree SET xp=?,lvl=lvl+?,skill_points=skill_points+?,new_lvl_collected=? WHERE user_id=?");
		$stmt->bindValue(1, $tot_xp, PDO::PARAM_INT);
		$stmt->bindValue(2, $new_lvl, PDO::PARAM_INT);
		$stmt->bindValue(3, $new_lvl, PDO::PARAM_INT);
		$stmt->bindValue(4, $new_lvl, PDO::PARAM_INT);
		$stmt->bindValue(5, $id, PDO::PARAM_INT);
		$stmt->execute();
			
		$new_money=$new_money+$money;

		$stmt = $db->prepare("UPDATE user SET money=? WHERE id=?");
		$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"STATUS\": \"OK\"\n,\"collected\": ".$reward.",\n\"new_lvl\": ".$new_lvl.",\n\"money\": ".$new_money."\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>