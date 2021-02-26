<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		if (!isset($_POST['sort'])) {
			$sort = "ageD";
		} else {
			$sort = $_POST['sort'];
		}
		$whitelist = Array( 'nameA', 'nameD', 'moneyA', 'moneyD', 'timeA', 'timeD', 'ageA', 'ageD' );
		if( !in_array( $sort, $whitelist ) )
			exit("An Error occured!");
		
		if ($sort=='nameA') {
			$sort = " order by user.username asc";
		}
		elseif ($sort=='nameD') {
			$sort = " order by user.username desc";
		}
		elseif ($sort=='moneyA') {
			$sort = " order by user.money asc";
		}
		elseif ($sort=='moneyD') {
			$sort = " order by user.money desc";
		}
		elseif ($sort=='ageA') {
			$sort = " order by days asc";
		}
		elseif ($sort=='ageD') {
			$sort = " order by days desc";
		}
		
		$stmt = $db->prepare("SELECT rat.attacker_malware,rat.defense_id,upgrades.hdd,upgrades.av,upgrades.firewall,DATEDIFF(NOW(),rat.timestamp) as days,user.username,user.ip,user.uuid,user.money FROM rat JOIN upgrades ON rat.defense_id = upgrades.id JOIN user on upgrades.id = user.id WHERE rat.attacker_id=? {$sort}");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\"my_rats\":[\n";
		$tot_rats = $stmt->rowCount();
		$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
		foreach ($arr as $row) {
			$safemoney = pow(2,(4+$row['hdd']))*1000;
			$money=$row['money']-$safemoney;
			if ($money<0) { $money=0; }
			$resp = $resp
			."{\"my_malware\": ".$row['attacker_malware'].",\n"
			."\"defense_av\": ".$row['av'].",\n"
			."\"defense_id\": ".$row['defense_id'].",\n"
			."\"defense_uuid\": \"".$row['uuid']."\",\n"
			."\"defense_user\": \"".$row['username']."\",\n"
			."\"defense_ip\": \"".long2ip($row['ip'])."\",\n"
			."\"defense_fw\": ".$row['firewall'].",\n"
			."\"money\": ".$money.",\n"
			."\"days\": ".$row['days'].",\n";
			$secs=0;
			$stmt = $db->prepare("SELECT timestamp, DATE_ADD(timestamp,INTERVAL 60 MINUTE) as next_attack,TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(timestamp,INTERVAL 60 MINUTE)) as a_interval FROM attack_log WHERE attacker_id=? and defense_id=? and DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $row['defense_id'], PDO::PARAM_INT);
			$stmt->execute();
			if ($stmt->rowCount() != 0) { 
				//Wait for next attack
				while($row2 = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$endtime = strtotime($row2['next_attack']);
					$secs = $row2['a_interval'];
				}
			}
			$resp=$resp."\"secs\": ".$secs."\n},";
		}
		$resp = $resp."],";
		$stmt = $db->prepare("SELECT COUNT(t1.id) as num_rats, upgrades.c2c FROM (SELECT rat.id, rat.defense_id FROM rat JOIN upgrades ON rat.defense_id = upgrades.id WHERE rat.defense_id=? and rat.attacker_malware < (upgrades.av+(upgrades.siem*0.25)+((rat.attacker_malware/100)*DATEDIFF(NOW(),rat.timestamp)))) as t1 RIGHT JOIN upgrades on t1.defense_id = upgrades.id  WHERE upgrades.id=? GROUP BY defense_id");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_c2c = $row['c2c'];
			$max_rats = 10+$my_c2c;
			$resp=$resp."\"my_rat_count\": ".$tot_rats.",\n"
			."\"max_rats\": ".$max_rats.",\n"
			."\"rat_on_me\": ".$row['num_rats'].",\n";
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