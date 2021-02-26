<?php
	if (!isset($_POST['type']))
		exit("An Error occured!");
	$type = $_POST['type'];
	$whitelist = Array( 'webs', 'apps', 'dbs', 'money', 'bot', 'rat' );
	if( !in_array( $type, $whitelist ) )
		exit("An Error occured!");
	$attack_type = $_POST['type'];
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$checkNonce=checkNonce($db,$id);
		if ($checkNonce!=true) { exit("Nonce Issue"); }
		
		$target = $_POST['target'];
		
		$stmt = $db->prepare("SELECT id FROM user WHERE uuid=?");
		$stmt->bindValue(1, $target, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { exit(); }
		else { 
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$target = $row['id'];
			}
		}
		
		if (($type != "bot") and ($type != "rat")) {
			$stmt = $db->prepare("SELECT timestamp, DATE_ADD(timestamp,INTERVAL 60 MINUTE) as next_attack,TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(timestamp,INTERVAL 60 MINUTE)) as a_interval FROM attack_log WHERE attacker_id=? and defense_id=? and DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $target, PDO::PARAM_INT);
			$stmt->execute();
			if ($stmt->rowCount() != 0) { 
				//Wait for next attack
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$endtime = strtotime($row['next_attack']);
					$interval = $row['a_interval'];
				}
				$resp = "{\n\"status\": \"WAIT\","
				."\"secs\": ".$interval."\n},";	
				exit(base64_encode($resp));
			}
		}
		
		$stmt = $db->prepare("SELECT upgrades.scan,upgrades.malware,upgrades.exploit,upgrades.anon,upgrades.c2c,user.money,user.reputation,user_stats.best_attack,skill_tree.st_pentester,skill_tree.st_pentester2,skill_tree.st_stealth,skill_tree.st_bank_exp,research.anonR1,research.anonR2,research.exploitR1,research.exploitR2,research.malwareR1,research.malwareR2 FROM upgrades JOIN user on upgrades.id = user.id JOIN skill_tree ON user.id=skill_tree.user_id JOIN research ON user.id=research.user_id JOIN user_stats ON user.id=user_stats.id where user.id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$my_malware = $row['malware'];
			$my_exploit = $row['exploit'];
			$my_money = $row['money'];
			$my_anon = $row['anon'];
			$my_c2c = $row['c2c'];
			$my_rep = $row['reputation'];
			$my_best_attack = $row['best_attack'];
			$st_pentester1 = $row['st_pentester'];
			$st_pentester2 = $row['st_pentester2'];
			$st_stealth = $row['st_stealth'];
			$st_bank_exp = $row['st_bank_exp'];
			$my_anonR1 = $row['anonR1'];
			$my_anonR2 = $row['anonR2'];
			$my_exploitR1 = $row['exploitR1'];
			$my_exploitR2 = $row['exploitR2'];
			$my_malwareR1 = $row['malwareR1'];
			$my_malwareR2 = $row['malwareR2'];
		}
		$stmt = $db->prepare("SELECT upgrades.*,user.username,user.ip,user.money,user.reputation,user_stats.worst_defense,skill_tree.st_dev1,skill_tree.st_dev2,skill_tree.st_analyst,skill_tree.st_safe_pay,research.fwR1,research.fwR2,research.siemR1,research.siemR2,research.ipsR1,research.ipsR2,research.avR1,research.avR2,research.progR1,research.progR2 FROM upgrades JOIN user ON upgrades.id = user.id JOIN skill_tree ON user.id=skill_tree.user_id JOIN research ON user.id=research.user_id JOIN user_stats ON user.id=user_stats.id where user.id=?");
		$stmt->bindValue(1, $target, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$user = $row['username'];
			$ip = $row['ip'];
			$worst_defense = $row['worst_defense'];
			$st_dev1 = $row['st_dev1'];
			$st_dev2 = $row['st_dev2'];
			$st_analyst = $row['st_analyst'];
			$st_safe_pay = $row['st_safe_pay'];
			$firewall = $row['firewall'];
			$ips = $row['ips'];
			$webs = $row['webs'];
			$apps = $row['apps'];
			$dbs = $row['dbs'];
			$av = $row['av'];
			$siem = $row['siem'];
			$fwR1 = $row['fwR1'];
			$fwR2 = $row['fwR2'];
			$siemR1 = $row['siemR1'];
			$siemR2 = $row['siemR2'];
			$ipsR1 = $row['ipsR1'];
			$ipsR2 = $row['ipsR2'];
			$avR1 = $row['avR1'];
			$avR2 = $row['avR2'];
			$progR1 = $row['progR1'];
			$progR2 = $row['progR2'];
			$safemoney = pow(2,(4+$row['hdd']))*1000;
			$money=$row['money']-$safemoney;
			if ($money<0) { $money=0; }
			$rep = $row['reputation'];
			
			//Research Contribution
			//Offensive
			$my_exploit=$my_exploit+round(($my_exploit/100*(0.1*$my_exploitR1))+($my_exploit/100*(0.2*$my_exploitR2)));
			$my_malware=$my_malware+round(($my_malware/100*(0.1*$my_malwareR1))+($my_malware/100*(0.2*$my_malwareR2)));
			$my_anon=$my_anon+round(($my_anon/100*(0.1*$my_anonR1))+($my_anon/100*(0.2*$my_anonR2)));
			//Defensive
			$firewall=$firewall+round(($firewall/100*(0.1*$fwR1))+($firewall/100*(0.2*$fwR2)));
			$ips=$ips+round(($ips/100*(0.1*$ipsR1))+($ips/100*(0.2*$ipsR2)));
			$webs=$webs+round(($webs/100*(0.1*$progR1))+($webs/100*(0.2*$progR2)));
			$apps=$apps+round(($apps/100*(0.1*$progR1))+($apps/100*(0.2*$progR2)));
			$dbs=$dbs+round(($dbs/100*(0.1*$progR1))+($dbs/100*(0.2*$progR2)));
			$av=$av+round(($av/100*(0.1*$avR1))+($av/100*(0.2*$avR2)));
			$siem=$siem+round(($siem/100*(0.1*$siemR1))+($siem/100*(0.2*$siemR2)));
						
			$resp = "{";
			//SUCCESS CHANCE SETTINGS
			$webChance = floor(($my_exploit*90)/($ips+$webs));
			$appChance = floor(($my_exploit*60)/($ips+$apps));
			$dbChance = floor(($my_exploit*30)/($ips+$dbs));
			$moneyChance = floor(($my_malware*50)/($av));
			$botChance = floor(($my_malware*50)/($av));
			if ($botChance>95) { $botChance=95; }
			$ratChance = floor(($my_malware*30)/($av));
			if ($ratChance>95) { $ratChance=95; }
			$anonChance = floor(($my_anon*100)/($firewall+($siem/5)));
			$final_chance = 0;
			//Skill Tree Contribution
			$webChance = $webChance+$st_pentester1+($st_pentester2*2);
			$appChance = $appChance+$st_pentester1+($st_pentester2*2);
			$dbChance = $dbChance+$st_pentester1+($st_pentester2*2);
			$webChance = $webChance-$st_dev1-($st_dev2*2);
			$appChance = $appChance-$st_dev1-($st_dev2*2);
			$dbChance = $dbChance-$st_dev1-($st_dev2*2);
			$anonChance = $anonChance+($st_stealth*2)-($st_analyst*2);
			
			//ATTACK
			$stolen_money = 0;
			$attack = random_int(0,100);
			$money_coefficient=($st_bank_exp*2)-($st_safe_pay*2);
			if ($type == "webs") {
				if ($webChance>95) { $webChance=95; }
				$final_chance = $webChance;
				//Chance Cheat
				if (($final_chance > 90) and ($attack < (100-$final_chance))) { $attack = random_int(0,100); $webChance=50; }
				if ($attack >= (100-$webChance)) {
					$resp = $resp."\"status\": \"WIN\",";
					$stolen_money = floor($money/100*(40+$money_coefficient));
				}
				else { $resp = $resp."\"status\": \"LOST\","; }
			}
			if ($type == "apps") {
				if ($appChance>95) { $appChance=95; }
				$final_chance = $appChance;
				//Chance Cheat
				if (($final_chance > 90) and ($attack < (100-$final_chance))) { $attack = random_int(0,100); $appChance=50; }
				if ($attack >= (100-$appChance)) {
					$resp = $resp."\"status\": \"WIN\",";
					$stolen_money = floor($money/100*(50+$money_coefficient));
				}
				else { $resp = $resp."\"status\": \"LOST\","; }
			}
			if ($type == "dbs") {
				if ($dbChance>95) { $dbChance=95; }
				$final_chance = $dbChance;
				//Chance Cheat
				if (($final_chance > 90) and ($attack < (100-$final_chance))) { $attack = random_int(0,100); $dbChance=50; }
				if ($attack >= (100-$dbChance)) {
					$resp = $resp."\"status\": \"WIN\",";
					$stolen_money = floor($money/100*(60+$money_coefficient));
				}
				else { $resp = $resp."\"status\": \"LOST\","; }
			}
			if ($type == "money") {
				if ($moneyChance>95) { $moneyChance=95; }
				$final_chance = $moneyChance;
				//Chance Cheat
				if (($final_chance > 90) and ($attack < (100-$final_chance))) { $attack = random_int(0,100); $moneyChance=50; }
				if ($attack >= (100-$moneyChance)) {
					$resp = $resp."\"status\": \"WIN\",";
					$stolen_money = floor($money/100*(45+$money_coefficient));
				}
				else { $resp = $resp."\"status\": \"LOST\","; }
			}
			if ($type == "bot") {
				$stmt = $db->prepare("SELECT count(id) as bot_number FROM botnet WHERE attacker_id = ?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$bot_number = $row['bot_number'];
				}
				if ($bot_number >= (10+($my_c2c*2))) { 
					$resp = "{\n\"status\": \"BOT_LIMIT\"\n}"; 
					exit(base64_encode($resp));
				}
				else {
					$stmt = $db->prepare("SELECT count(id) as bot_number FROM botnet WHERE defense_id = ?");
					$stmt->bindValue(1, $target, PDO::PARAM_INT);
					$stmt->execute();	
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
						$bot_number = $row['bot_number'];
					}
					if ($bot_number >= 50) { 
						$resp = "{\n\"status\": \"TOO_MANY_BOT\"\n}"; 
						exit(base64_encode($resp));
					}
					else {
						$stmt = $db->prepare("SELECT id FROM botnet WHERE attacker_id = ? and defense_id = ?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->bindValue(2, $target, PDO::PARAM_INT);
						$stmt->execute();	
						if ($stmt->rowCount() != 0) {
							$resp = "{\n\"status\": \"BOT_ALREADY_INFECTED\"\n}"; 
							exit(base64_encode($resp));
						}
						else {
							$stmt = $db->prepare("SELECT id,DATE_ADD(timestamp,INTERVAL 60 MINUTE) as next_attack,TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(timestamp,INTERVAL 60 MINUTE)) as a_interval FROM `bot_attempt` WHERE attacker_id=? and defense_id=? and type='bot' and DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp");
							$stmt->bindValue(1, $id, PDO::PARAM_INT);
							$stmt->bindValue(2, $target, PDO::PARAM_INT);
							$stmt->execute();	
							if ($stmt->rowCount() >= 3) {
								while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
									$endtime = strtotime($row['next_attack']);
									$interval = $row['a_interval'];
								}
								$resp = "{\n\"status\": \"BOT_3_ATTEMPTS\","
								."\"secs\": ".$interval."\n},";					
								exit(base64_encode($resp));
							}
							else {
								if ($attack >= (100-$botChance)) { $resp = $resp."\"status\": \"WIN\","; }
								else { 
									$stmt = $db->prepare("INSERT INTO bot_attempt (attacker_id, defense_id, type, timestamp) VALUES (?,?,?,NOW())");
									$stmt->bindValue(1, $id, PDO::PARAM_INT);
									$stmt->bindValue(2, $target, PDO::PARAM_INT);
									$stmt->bindValue(3, $type, PDO::PARAM_STR);
									$stmt->execute();			
									$resp = $resp."\"status\": \"LOST\","; 
								}
							}
						}
					}
				}
			}
			if ($type == "rat") {
				$stmt = $db->prepare("SELECT count(id) as rat_number FROM rat WHERE attacker_id = ?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
					$rat_number = $row['rat_number'];
				}
				if ($rat_number >= (10+($my_c2c))) { 
					$resp = "{\n\"status\": \"RAT_LIMIT\"\n}"; 
					exit(base64_encode($resp));
				}
				else {
					$stmt = $db->prepare("SELECT count(id) as rat_number FROM rat WHERE defense_id = ?");
					$stmt->bindValue(1, $target, PDO::PARAM_INT);
					$stmt->execute();	
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
						$rat_number = $row['rat_number'];
					}
					if ($rat_number >= 50) { 
						$resp = "{\n\"status\": \"TOO_MANY_RAT\"\n}"; 
						exit(base64_encode($resp));
					}
					else {
						$stmt = $db->prepare("SELECT id FROM rat WHERE attacker_id = ? and defense_id = ?");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->bindValue(2, $target, PDO::PARAM_INT);
						$stmt->execute();	
						if ($stmt->rowCount() != 0) {
							$resp = "{\n\"status\": \"RAT_ALREADY_INFECTED\"\n}"; 
							exit(base64_encode($resp));
						}
						else {
							$stmt = $db->prepare("SELECT id,DATE_ADD(timestamp,INTERVAL 60 MINUTE) as next_attack,TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(timestamp,INTERVAL 60 MINUTE)) as a_interval FROM `bot_attempt` WHERE attacker_id=? and defense_id=? and type='rat' and DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp");
							$stmt->bindValue(1, $id, PDO::PARAM_INT);
							$stmt->bindValue(2, $target, PDO::PARAM_INT);
							$stmt->execute();	
							if ($stmt->rowCount() >= 3) {
								while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
									$endtime = strtotime($row['next_attack']);
									$interval = $row['a_interval'];
								}
								$resp = "{\n\"status\": \"RAT_3_ATTEMPTS\","
								."\"secs\": ".$interval."\n},";					
								exit(base64_encode($resp));
							}
							else {
								if ($attack >= (100-$ratChance)) { $resp = $resp."\"status\": \"WIN\","; }
								else { 
									$stmt = $db->prepare("INSERT INTO bot_attempt (attacker_id, defense_id, type, timestamp) VALUES (?,?,?,NOW())");
									$stmt->bindValue(1, $id, PDO::PARAM_INT);
									$stmt->bindValue(2, $target, PDO::PARAM_INT);
									$stmt->bindValue(3, $type, PDO::PARAM_STR);
									$stmt->execute();	
									$resp = $resp."\"status\": \"LOST\","; 
								}
							}
						}
					}
				}
			}
			//ANONYMOUS?
			if ($anonChance > 100) { $anonChance = 100; }
			$anon = rand(0,100);
			if ($anon >= (100-$anonChance)) { $anon = 1; } else $anon = 0;
			
			//REPUTATION PRIZE
			$prize_rep = round((($rep-$my_rep)/10)+25);
			if ($prize_rep > 50) { $prize_rep = 50; }
			if ($prize_rep < 0) { $prize_rep = 0; }
			
			//WIN
			if (strpos($resp, 'WIN') !== false) {
				$new_money = $money - $stolen_money;
				//Target Crew
				$target_crew=0;
				$stmt = $db->prepare("SELECT user.crew FROM user WHERE user.id=?");
				$stmt->bindValue(1, $target, PDO::PARAM_INT);
				$stmt->execute();
				if ($stmt->rowCount() != 0) {
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
						$target_crew=$row['crew'];
					}
				}
				//Get Crew and Wallet Percentage
				$stmt = $db->prepare("SELECT crew.wallet_p,crew.id,crew.daily_wallet,user.crew_daily_contribution,(SELECT count(id) as members FROM user WHERE crew=(SELECT crew FROM user WHERE id=?)) as members FROM user JOIN crew ON user.crew = crew.id WHERE user.id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();			
				
				if ($stmt->rowCount() != 0) {
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
						$my_crew=$row['id'];
						$daily_wallet=$row['daily_wallet'];
						$daily_user_wallet=$row['crew_daily_contribution'];
						$members=$row['members'];
						if (($target_crew!=$my_crew) and ($daily_user_wallet<5000000) and ($daily_wallet<(5000000*$members))) {
							$crew_wallet_money = round($stolen_money/100*$row['wallet_p']);
							if (($daily_user_wallet+$crew_wallet_money)>5000000) { $crew_wallet_money=5000000-$daily_user_wallet; }
							if (($daily_wallet+$crew_wallet_money)>(5000000*$members)) { $crew_wallet_money=(5000000*$members)-$daily_wallet; }
							$stmt = $db->prepare("UPDATE crew SET wallet=wallet+?,daily_wallet=daily_wallet+? where id=?");
							$stmt->bindValue(1, $crew_wallet_money, PDO::PARAM_INT);
							$stmt->bindValue(2, $crew_wallet_money, PDO::PARAM_INT);
							$stmt->bindValue(3, $row['id'], PDO::PARAM_INT);
							$stmt->execute();	
							$stmt = $db->prepare("UPDATE user SET crew_contribution=crew_contribution+?,crew_daily_contribution=crew_daily_contribution+? where id=?");
							$stmt->bindValue(1, $crew_wallet_money, PDO::PARAM_INT);
							$stmt->bindValue(2, $crew_wallet_money, PDO::PARAM_INT);
							$stmt->bindValue(3, $id, PDO::PARAM_INT);
							$stmt->execute();	
							$stolen_money=$stolen_money-$crew_wallet_money;
						}
					}
				}
				$my_new_money = $my_money + $stolen_money;	
				$rep_change = $prize_rep;
				$result = 1;				
				if ($new_money < 0) { $new_money = 0; }
				if (($type != "bot") and ($type != "rat")) {
					//UPDATE MONEY and REP and WRITE LOG
					$stmt = $db->prepare("UPDATE user SET money=money-?, reputation=? where id=?");
					$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(2, $rep-$prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(3, $target, PDO::PARAM_INT);
					$stmt->execute();	
					$stmt = $db->prepare("UPDATE user SET money=?, reputation=? where id=?");
					$stmt->bindValue(1, $my_new_money, PDO::PARAM_INT);
					$stmt->bindValue(2, $my_rep+$prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();		
					
					$stmt = $db->prepare("UPDATE economy SET hacks=hacks+?, income=income+? where user_id=?");
					$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(2, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(3, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE economy SET money_lost=money_lost+? where user_id=?");
					$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->execute();
					
					$stmt = $db->prepare("INSERT INTO attack_log (attacker_id, defense_id, type, result, money_stolen, rep_change, anon, timestamp, attack_chance, attack_result) VALUES (?,?,?,?,?,?,?,NOW(),?,?)");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->bindValue(3, $type, PDO::PARAM_STR);
					$stmt->bindValue(4, $result, PDO::PARAM_INT);
					$stmt->bindValue(5, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(6, $rep_change, PDO::PARAM_INT);
					$stmt->bindValue(7, $anon, PDO::PARAM_INT);
					$stmt->bindValue(8, $final_chance, PDO::PARAM_INT);
					$stmt->bindValue(9, $attack, PDO::PARAM_INT);
					$stmt->execute();			
					//SET NEGATIVE REPUTATION TO 0
					$stmt = $db->prepare("UPDATE user SET reputation=0 where reputation<0 and id=?");
					$stmt->bindValue(1, $target, PDO::PARAM_INT);
					$stmt->execute();	
					
					if ($stolen_money > $my_best_attack) { $my_best_attack = $stolen_money; }
					//UPDATE STATS
					$stmt = $db->prepare("UPDATE user_stats SET attack=attack+1, attack_w=attack_w+1, money_w=money_w+?, rep_w=rep_w+?, best_attack=? where id=?");
					$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(2, $prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(3, $my_best_attack, PDO::PARAM_INT);
					$stmt->bindValue(4, $id, PDO::PARAM_INT);
					$stmt->execute();
					if ($stolen_money > $worst_defense) { $worst_defense = $stolen_money; }
					$stmt = $db->prepare("UPDATE user_stats SET defense=defense+1, defense_l=defense_l+1, money_l=money_l+?, rep_l=rep_l+?, worst_defense=? where id=?");
					$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(2, $prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(3, $worst_defense, PDO::PARAM_INT);
					$stmt->bindValue(4, $target, PDO::PARAM_INT);
					$stmt->execute();
					
					//TOURNAMENT HACK
					$stmt = $db->prepare("SELECT tournaments_new.type FROM `tournaments_new` WHERE CURTIME()>time_start ORDER BY time_start desc LIMIT 1");
					$stmt->execute();
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
							$current = $row['type'];
					}
					if ($current == 1) {
						$stmt = $db->prepare("UPDATE tournament_hack SET hack_count=hack_count+1, money_hack=money_hack+? WHERE id=? AND hack_count<100");
						$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
						$stmt->bindValue(2, $id, PDO::PARAM_INT);
						$stmt->execute();
					}
					elseif ($current == 3) {
						//Hack&Defend Tournament
						$stmt = $db->prepare("UPDATE tournament_hackdefend SET hack_count=hack_count+1, money_hack=money_hack+? WHERE id=? AND hack_count<100");
						$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
						$stmt->bindValue(2, $id, PDO::PARAM_INT);
						$stmt->execute();	

						$stmt = $db->prepare("UPDATE tournament_hackdefend SET money_hack=money_hack-? WHERE id=?");
						$stmt->bindValue(1, $stolen_money, PDO::PARAM_INT);
						$stmt->bindValue(2, $target, PDO::PARAM_INT);
						$stmt->execute();									
					}
				}
				elseif ($type == "bot") {
					$stmt = $db->prepare("INSERT INTO botnet (attacker_id, defense_id, attacker_malware, timestamp) VALUES (?,?,?,NOW())");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->bindValue(3, $my_malware, PDO::PARAM_INT);
					$stmt->execute();		
					$resp = "{\n\"status\": \"WIN\",\n\"type\": \"".$type."\"\n}"; 
					exit(base64_encode($resp));
				}
				elseif ($type == "rat") {
					$stmt = $db->prepare("INSERT INTO rat (attacker_id, defense_id, attacker_malware, timestamp) VALUES (?,?,?,NOW())");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->bindValue(3, $my_malware, PDO::PARAM_INT);
					$stmt->execute();		
					$resp = "{\n\"status\": \"WIN\",\n\"type\": \"".$type."\"\n}"; 
					exit(base64_encode($resp));
				}
			}
			
			//LOST
			if (strpos($resp, 'LOST') !== false) {
				$my_new_money = 0;
				$result = 0;
				$prize_rep = 50-$prize_rep;
				$rep_change = -$prize_rep;
				if (($type != "bot") and ($type != "rat")) {
					//UPDATE REP and WRITE LOG
					$stmt = $db->prepare("UPDATE user SET reputation=? where id=?");
					$stmt->bindValue(1, $rep+$prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->execute();	
					$stmt = $db->prepare("UPDATE user SET reputation=? where id=?");
					$stmt->bindValue(1, $my_rep-$prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(2, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("INSERT INTO attack_log (attacker_id, defense_id, type, result, money_stolen, rep_change, anon, timestamp, attack_chance, attack_result) VALUES (?,?,?,?,?,?,?,NOW(),?,?)");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->bindValue(3, $type, PDO::PARAM_STR);
					$stmt->bindValue(4, $result, PDO::PARAM_INT);
					$stmt->bindValue(5, $stolen_money, PDO::PARAM_INT);
					$stmt->bindValue(6, $rep_change, PDO::PARAM_INT);
					$stmt->bindValue(7, $anon, PDO::PARAM_INT);
					$stmt->bindValue(8, $final_chance, PDO::PARAM_INT);
					$stmt->bindValue(9, $attack, PDO::PARAM_INT);
					$stmt->execute();				
					//SET NEGATIVE REPUTATION TO 0
					$stmt = $db->prepare("UPDATE user SET reputation=0 where reputation<0 and id=?");
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();
					//UPDATE STATS
					$stmt = $db->prepare("UPDATE user_stats SET attack=attack+1, attack_l=attack_l+1, rep_l=rep_l+? where id=?");
					$stmt->bindValue(1, $prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(2, $id, PDO::PARAM_INT);
					$stmt->execute();
					$stmt = $db->prepare("UPDATE user_stats SET defense=defense+1, defense_w=defense_w+1, rep_w=rep_w+? where id=?");
					$stmt->bindValue(1, $prize_rep, PDO::PARAM_INT);
					$stmt->bindValue(2, $target, PDO::PARAM_INT);
					$stmt->execute();
					//TOURNAMENT HACK
					$stmt = $db->prepare("SELECT tournaments.type FROM `tournaments` WHERE CURTIME()>time_start ORDER BY time_start desc LIMIT 1");
					$stmt->execute();
					while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
							$current = $row['type'];
					}
					if ($current == 1) {
						$stmt = $db->prepare("UPDATE tournament_hack SET hack_count=hack_count+1 WHERE id=? AND hack_count<100");
						$stmt->bindValue(1, $id, PDO::PARAM_INT);
						$stmt->execute();		
					}
				}
				elseif ($type == "bot") {	
					$resp = "{\n\"status\": \"LOST\",\n\"type\": \"".$type."\"\n}"; 
					exit(base64_encode($resp));
				}
				elseif ($type == "rat") {
					$resp = "{\n\"status\": \"LOST\",\n\"type\": \"".$type."\"\n}"; 
					exit(base64_encode($resp));
				}
			}
			
			//RESPONSE
			$resp = "{\"ip\": \"".long2ip($ip)."\","
			."\"result\": ".$result.","
			."\"type\": \"".$type."\","
			."\"rep_change\": \"".$rep_change."\","
			."\"new_money\": \"".$my_new_money."\","
			."\"anon\": ".$anon.","
			."\"stolen_money\": ".$stolen_money."}";
		}						
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>