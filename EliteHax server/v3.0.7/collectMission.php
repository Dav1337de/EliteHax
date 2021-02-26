<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	if (!isset($_POST['mission_id'])) { exit(); }
	$mission_id = $_POST['mission_id'];
		
	try {
		$id = getIdFromToken($db);
				
		$stmt = $db->prepare("SELECT missions_available.reward,user.money,missions_available.xp as mxp, skill_tree.lvl, skill_tree.xp as xp FROM `missions_available` JOIN user ON missions_available.user_id=user.id JOIN skill_tree ON user.id=skill_tree.user_id WHERE missions_available.user_id=? and missions_available.id=? and (NOW()-time_finish)>0 and running=1");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $mission_id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { exit(); }
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$money = $row['money'];
			$reward = $row['reward'];
			$new_money=$money+$reward;
			//XP
			$new_xp = $row['mxp'];
			$old_xp = $row['xp'];
			$tot_xp=$old_xp+$new_xp;
			$clvl = $row['lvl'];
			$lvl=$clvl+1;
			$new_lvl=0;
			$finished=false;
			$new_base=sommatoria($clvl);
			while (($lvl<=65) and ($finished==false)) {
				$sum=sommatoria($lvl);
				if ($sum > $tot_xp) { $finished=true; }
				else { $lvl++; $new_lvl++; $new_base=$sum; }
			}	

			$stmt = $db->prepare("UPDATE user SET money=? WHERE id=?");
			$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("UPDATE user_stats SET missions=missions+1 WHERE id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();

			$stmt = $db->prepare("UPDATE economy SET missions=missions+?, income=income+? where user_id=?");
			$stmt->bindValue(1, $reward, PDO::PARAM_INT);
			$stmt->bindValue(2, $reward, PDO::PARAM_INT);
			$stmt->bindValue(3, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("UPDATE skill_tree SET xp=?,lvl=lvl+?,skill_points=skill_points+?,new_lvl_collected=? WHERE user_id=?");
			$stmt->bindValue(1, $tot_xp, PDO::PARAM_INT);
			$stmt->bindValue(2, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(3, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(4, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(5, $id, PDO::PARAM_INT);
			$stmt->execute();
			$resp = "{\n\"STATUS\": \"OK\"\n,\"collected\": ".$reward.",\n\"new_lvl\": ".$new_lvl.",\n\"money\": ".$new_money."\n}";
			$stmt = $db->prepare("DELETE FROM missions_available WHERE id=?");
			$stmt->bindValue(1, $mission_id, PDO::PARAM_INT);
			$stmt->execute();			
		}
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>