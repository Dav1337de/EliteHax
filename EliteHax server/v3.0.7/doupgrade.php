<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	if (!isset($_POST['type']))
		exit("An Error occured!");
	$type = $_POST['type'];
	$whitelist = Array( 'internet', 'siem', 'firewall', 'ips', 'c2c', 'anon', 'webs', 'apps', 'dbs', 'cpu', 'ram', 'hdd', 'gpu', 'fan', 'av', 'malware', 'exploit', 'scan', 'cryptominer' );
	if( !in_array( $type, $whitelist ) )
		exit("An Error occured!");
	try {
		$id = getIdFromToken($db);
		
		$checkNonce=checkNonce($db,$id);
		if ($checkNonce!=true) { exit("Nonce Issue"); }
		
		$db->beginTransaction();
		$typet = $type."_task";		
		$stmt = $db->prepare("SELECT upgrades.{$type},upgrades.{$typet},user.money,upgrades.internet,upgrades.cpu,upgrades.ram,(SELECT COUNT(id) FROM `task` where id=?) as tasks, skill_tree.st_upgrade_speed, skill_tree.st_upgrade_cost, research.upgradeR1, research.upgradeR2 FROM upgrades JOIN user ON upgrades.id = user.id JOIN skill_tree ON user.id=skill_tree.user_id JOIN research ON user.id=research.user_id WHERE user.id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$new_lvl = $row[$typet]+1;
			$cur_task_lvl = $row[$typet];
			$cur_lvl = $row[$type];
			$st_upgrade_speed = $row['st_upgrade_speed'];
			$st_upgrade_cost = $row['st_upgrade_cost'];
			$upgradeR1 = $row['upgradeR1'];
			$upgradeR2 = $row['upgradeR2'];
			//CHECK UPPER LIMIT
			if (((($type == 'internet') or ($type == 'cpu') or ($type == 'ram') or ($type == 'hdd') or ($type == 'c2c') or ($type == 'fan') or ($type == 'cryptominer')) and ($cur_task_lvl == 10)) or ($cur_task_lvl == 99999)) {
				$resp = "{\n\"status\": \"MAX_LVL\"\n}";
				exit(base64_encode($resp));		
			}
			//CHECK TASK NUMBER vs RAM
			$ram = $row['ram'];
			$tasks = $row['tasks'];
			if ($tasks >= ($ram+6)) {
				$resp = "{\n\"status\": \"MAX_TASK\"\n}";
				exit(base64_encode($resp));	
			}
			$internet = $row['internet'];
			$cpu = $row['cpu'];
			$cur_money = $row['money'];
			$time_array = getTime($type,$new_lvl,$internet,$cpu);
			$time_part1 = $time_array[0];
			$time_part2 = $time_array[1];
			$time = $time_array[2];
			$money = getMoney($type,$new_lvl);
			$cost = getMoney($type,$new_lvl+1);
			$next_time_temp = getTime($type,$new_lvl+1,$internet,$cpu);
			$next_time = $next_time_temp[2];
			if ($st_upgrade_speed>0) { $next_time=$next_time-round($next_time/100*($st_upgrade_speed*2)); }
			//Skill Tree Contribution
			$time_part3 = round($time/100*($st_upgrade_speed*2));
			if ($st_upgrade_speed>0) { $time=$time-round($time/100*($st_upgrade_speed*2)); }
			$money=$money-round($money/100*($st_upgrade_cost*2));
			$cost=$cost-round($cost/100*($st_upgrade_cost*2));
			
			//Research Contribution
			$time=$time-round($time/100*($upgradeR2*0.2));
			$next_time=$next_time-round($next_time/100*($upgradeR2*0.2));
			$money=$money-round($money/100*($upgradeR1*0.2));
			$cost=$cost-round($cost/100*($upgradeR1*0.2));
			
			if ($cur_money < $money) {
				$resp = "{\n\"status\": \"NO_MONEY\"\n}";
				echo base64_encode($resp);
				exit();
			}			
			else {
				$new_money = $cur_money - $money;
			}
			$stmt = $db->prepare("INSERT INTO task (id, type, lvl, starttime, endtime,duration,part1,part2,part3) VALUES (?,?,?,NOW(),NOW() + INTERVAL {$time} SECOND,?,?,?,?)");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $type, PDO::PARAM_STR);
			$stmt->bindValue(3, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(4, $time, PDO::PARAM_INT);
			$stmt->bindValue(5, $time_part1, PDO::PARAM_INT);
			$stmt->bindValue(6, $time_part2, PDO::PARAM_INT);
			$stmt->bindValue(7, $time_part3, PDO::PARAM_INT);
			$stmt->execute();				
		}
		
		$stmt = $db->prepare("UPDATE upgrades SET {$typet}=? where id=?");
		$stmt->bindValue(1, $new_lvl, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE user SET money=? where id=?");
		$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE economy SET upgrades=upgrades+? where user_id=?");
		$stmt->bindValue(1, $money, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();	
		
		$stmt = $db->prepare("UPDATE user_stats SET money_spent=money_spent+?,upgrades=upgrades+1 where id=?");
		$stmt->bindValue(1, $money, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		$db->commit();
		
		$resp = "{\n"
			."\"status\": \"OK\",\n"
			."\"money\": ".$new_money.",\n"
			."\"time\": ".$time.",\n"
			."\"new_cost\": ".$cost.",\n"
			."\"new_time\": ".$next_time.",\n"
			."\"new_lvl\": ".($new_lvl)."\n}";
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>
