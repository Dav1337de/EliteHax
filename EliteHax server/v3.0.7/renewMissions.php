<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT count(missions_available.id) as available_missions, upgrades.gpu, mission_center.lvl,skill_tree.st_mission_speed,skill_tree.st_mission_reward,research.missionR1,research.missionR2,research.missionR3 FROM upgrades JOIN mission_center ON upgrades.id = mission_center.user_id JOIN skill_tree ON upgrades.id=skill_tree.user_id JOIN research ON upgrades.id=research.user_id LEFT JOIN `missions_available` ON upgrades.id=missions_available.user_id WHERE upgrades.id=? GROUP BY missions_available.user_id");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$mission_ctrl_lvl = $row['lvl'];
			$st_mission_speed=$row['st_mission_speed'];
			$st_mission_reward=$row['st_mission_reward'];
			$missionR1 = $row['missionR1'];
			$missionR2 = $row['missionR2'];
			$missionR3 = $row['missionR3'];
		    if ($row['available_missions'] == 0) {
				for ($i = 1; $i <= (3+(2*($mission_ctrl_lvl-1))); $i++) {
					$difficult = rand(1,$mission_ctrl_lvl);
					$mission_type = rand(1,3);
					if ($mission_type == 1) { $mission_subtype = rand(1,6); }
					elseif ($mission_type == 2) { $mission_subtype = rand(1,3); }
					elseif ($mission_type == 3) { $mission_subtype = 1; }
					$duration = mission_duration($difficult);
					if ($mission_ctrl_lvl==1) { $modifier=10; }
					elseif ($mission_ctrl_lvl==2) { $modifier=8; }
					elseif ($mission_ctrl_lvl==3) { $modifier=6; }
					elseif ($mission_ctrl_lvl==4) { $modifier=4; }
					elseif ($mission_ctrl_lvl==5) { $modifier=2.8; }
					$reward = mission_reward($difficult,$row['gpu'])*$modifier;
					$xp = mission_xp($difficult);
					
					//Skill Tree Contribution
					$duration=$duration-round($duration/100*(2*$st_mission_speed));
					$reward=round($reward+($reward/100*(2*$st_mission_reward)));
					//Research Contribution
					$duration=$duration-round($duration/100*(0.2*$missionR1));
					$reward=round($reward+($reward/100*(0.2*$missionR2)));
					$xp=round($xp+($xp/100*(0.5*$missionR3)));					

					$stmt = $db->prepare("INSERT INTO missions_available (user_id, type, subtype, difficult, duration, reward, xp) VALUES (?,?,?,?,?,?,?)");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $mission_type, PDO::PARAM_INT);
					$stmt->bindValue(3, $mission_subtype, PDO::PARAM_STR);
					$stmt->bindValue(4, $difficult, PDO::PARAM_STR);
					$stmt->bindValue(5, $duration, PDO::PARAM_INT);
					$stmt->bindValue(6, $reward, PDO::PARAM_INT);
					$stmt->bindValue(7, $xp, PDO::PARAM_INT);
					$stmt->execute();	
				}
			}
		}
		$resp = "{\n\"status\": \"OK\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>