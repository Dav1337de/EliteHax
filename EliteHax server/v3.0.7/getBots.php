<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT botnet.attacker_malware,upgrades.av,upgrades.gpu,DATEDIFF(NOW(),botnet.timestamp) as days,user.uuid FROM botnet JOIN upgrades ON botnet.defense_id = upgrades.id JOIN user ON upgrades.id = user.id WHERE botnet.attacker_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"my_bots\":[\n";
		$tot_bots = $stmt->rowCount();
		$tot_income = 0;
		$tot_gpu = 0;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$defense_gpu = $row['gpu'];
			if (($tot_gpu+$defense_gpu) > 30000) {
			  if ($tot_gpu<=30000) { $income=((30000-$tot_gpu)*50)+($tot_gpu+$defense_gpu-30000)*25; }
			  else { $income=$defense_gpu*25; }
			}
			elseif (($tot_gpu+$defense_gpu) > 20000) {
			  if ($tot_gpu<=20000) { $income=((20000-$tot_gpu)*75)+($tot_gpu+$defense_gpu-20000)*50; }
			  else { $income=$defense_gpu*50; }
			}
			elseif (($tot_gpu+$defense_gpu) > 10000) {
			  if ($tot_gpu<=10000) { $income=((10000-$tot_gpu)*100)+($tot_gpu+$defense_gpu-10000)*75; }
			  else { $income=$defense_gpu*75; }
			}
			else { $income=$defense_gpu*100; }
			$tot_gpu = $tot_gpu+$defense_gpu;
			$tot_income = $tot_income+$income;
			$resp = $resp
			."{\"my_malware\": ".$row['attacker_malware'].",\n"
			."\"defense_av\": ".$row['av'].",\n"
			."\"defense_uuid\": \"".$row['uuid']."\",\n"
			."\"income\": ".$income.",\n"
			."\"days\": ".$row['days']."\n},";
		}
		$resp = $resp."],";
		$stmt = $db->prepare("SELECT COUNT(t1.id) as num_bots, upgrades.c2c, skill_tree.st_hourly FROM (SELECT botnet.id, botnet.defense_id FROM botnet JOIN upgrades ON botnet.defense_id = upgrades.id WHERE botnet.defense_id=? and botnet.attacker_malware < (upgrades.av+(upgrades.siem*0.25)+((botnet.attacker_malware/100)*DATEDIFF(NOW(),botnet.timestamp)))) as t1 RIGHT JOIN upgrades on t1.defense_id = upgrades.id JOIN skill_tree ON upgrades.id=skill_tree.user_id WHERE upgrades.id=? GROUP BY defense_id");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$st_hourly=$row['st_hourly'];
			$tot_income=($tot_income*2)+20000+($st_hourly*20000);
			$tot_income = $tot_income+($tot_income/100*($st_hourly*2));
			$my_c2c = $row['c2c'];
			$max_bots = 10+(2*$my_c2c);
			$resp=$resp."\"my_bot_count\": ".$tot_bots.",\n"
			."\"tot_income\": ".$tot_income.",\n"
			."\"max_bots\": ".$max_bots.",\n"
			."\"bot_on_me\": ".$row['num_bots'].",\n";
		}
		$stmt = $db->prepare("SELECT username,money FROM user WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp=$resp."\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money']."\n";
		}
		
		$resp = $resp."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>