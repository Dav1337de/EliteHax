<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT upgrades.scan,upgrades.malware,upgrades.exploit,upgrades.anon,user.reputation,skill_tree.st_pentester,skill_tree.st_pentester2,skill_tree.st_stealth,skill_tree.st_bank_exp FROM upgrades JOIN user ON upgrades.id = user.id JOIN skill_tree ON upgrades.id=skill_tree.user_id where user.id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$my_scan = $row['scan'];
			$my_malware = $row['malware'];
			$my_exploit = $row['exploit'];
			$my_anon = $row['anon'];
			$my_rep = $row['reputation'];
			$st_pentester1 = $row['st_pentester'];
			$st_pentester2 = $row['st_pentester2'];
			$st_stealth = $row['st_stealth'];
			$st_bank_exp = $row['st_bank_exp'];
		}
		$stmt = $db->prepare("SELECT upgrades.*,user.username,user.ip,user.money,user.reputation,user.id,crew.name,skill_tree.st_dev1,skill_tree.st_dev2,skill_tree.st_analyst,skill_tree.st_safe_pay FROM upgrades JOIN user ON upgrades.id = user.id JOIN skill_tree ON user.id=skill_tree.user_id LEFT JOIN crew ON user.crew = crew.id where user.ip=?");
		$stmt->bindValue(1, sprintf('%u', ip2long($_POST['target'])), PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			echo base64_encode("{\"ip\": \"No\"}");
			exit();
		}
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['id'] == $id) { echo base64_encode("{\"ip\": \"No\"}"); exit(); }
			$user = $row['username'];
			$ip = $row['ip'];
			$rep = $row['reputation'];
			$firewall = $row['firewall'];
			$st_dev1 = $row['st_dev1'];
			$st_dev2 = $row['st_dev2'];
			$st_analyst = $row['st_analyst'];
			$st_safe_pay = $row['st_safe_pay'];
			//SCAN SETTINGS
			$safemoney = pow(2,(3+$row['hdd']))*1000;
			$money=$row['money']-$safemoney;
			if ($money<0) { $money=0; }
			if ($my_scan >= $firewall*1.3) { $user = $row['username']; } else $user = "?";
			if ($my_scan >= $firewall*1.5) { $crew = $row['name']; } else $crew = "?";
			if ($crew == "") { $crew = "None"; }
			if ($my_scan >= $firewall*0.8) { $ips = $row['ips']; } else $ips = "?";
			if ($my_scan >= $firewall*0.8) { $webs = $row['webs']; } else $webs = "?";
			if ($my_scan >= $firewall) { $apps = $row['apps']; } else $apps = "?";
			if ($my_scan >= $firewall*1.2) { $dbs = $row['dbs']; } else $dbs = "?";
			if ($my_scan >= $firewall) { $av = $row['av']; } else $av = "?";
			if ($my_scan >= $firewall*1.3) { $malware = $row['malware']; } else $malware = "?";
			if ($my_scan >= $firewall*1.3) { $exploit = $row['exploit']; } else $exploit = "?";
			if ($my_scan >= $firewall*1.3) { $money = $money; } else $money = "?";
			//SUCCESS CHANCE SETTINGS
			$webChance = floor(($my_exploit*90)/($row['ips']+$row['webs']));
			$appChance = floor(($my_exploit*60)/($row['ips']+$row['apps']));
			$dbChance = floor(($my_exploit*30)/($row['ips']+$row['dbs']));
			$moneyChance = floor(($my_malware*50)/($row['av']));
			$botChance = floor(($my_malware*50)/($row['av']));
			$ratChance = floor(($my_malware*30)/($row['av']));
			$anonChance = floor(($my_anon*100)/($firewall+($row['siem']/5)));
			//Skill Tree Contribution
			$webChance = $webChance+$st_pentester1+($st_pentester2*2);
			$appChance = $appChance+$st_pentester1+($st_pentester2*2);
			$dbChance = $dbChance+$st_pentester1+($st_pentester2*2);
			$webChance = $webChance-$st_dev1-($st_dev2*2);
			$appChance = $appChance-$st_dev1-($st_dev2*2);
			$dbChance = $dbChance-$st_dev1-($st_dev2*2);
			$anonChance = $anonChance+($st_stealth*2)-($st_analyst*2);
			//Success Cap 95%
			if ($webChance > 95) { $webChance = 95; } if (($webs == "?") or ($ips == "?") or ($webChance < 10)) { $webChance = "??"; }
			if ($appChance > 95) { $appChance = 95; } if (($apps == "?") or ($ips == "?") or ($appChance < 10)) { $appChance = "??"; }
			if ($dbChance > 95) { $dbChance = 95; } if (($dbs == "?") or ($ips == "?") or ($dbChance < 10)) { $dbChance = "??"; }			
			if ($moneyChance > 95) { $moneyChance = 95; } if (($av == "?") or ($moneyChance < 10)) { $moneyChance = "??"; }		
			if ($botChance > 95) { $botChance = 95; } if (($av == "?") or ($botChance < 10)) { $botChance = "??"; }			
			if ($ratChance > 95) { $ratChance = 95; } if (($av == "?") or ($ratChance < 10)) { $ratChance = "??"; }
			if ($anonChance > 100) { $anonChance = 100; } if ($anonChance < 0) { $anonChance = 0; }
			
			//REPUTATION PRIZE
			$prize_rep = round((($rep-$my_rep)/10)+25);
			if ($prize_rep > 50) { $prize_rep = 50; }
			if ($prize_rep < 0) { $prize_rep = 0; }
			$rep_change = "+".$prize_rep." / -".(50-$prize_rep);
			
			$resp = "{\"user\": \"".$user."\","
			."\"crew\": \"".$crew."\","
			."\"firewall\": \"".$firewall."\","
			."\"ips\": \"".$ips."\","
			."\"webs\": \"".$webs."\","
			."\"apps\": \"".$apps."\","
			."\"dbs\": \"".$dbs."\","
			."\"av\": \"".$av."\","
			."\"malware\": \"".$malware."\","
			."\"exploit\": \"".$exploit."\","
			."\"webChance\": \"".$webChance."\","
			."\"appChance\": \"".$appChance."\","
			."\"dbChance\": \"".$dbChance."\","
			."\"moneyChance\": \"".$moneyChance."\","
			."\"botChance\": \"".$botChance."\","
			."\"ratChance\": \"".$ratChance."\","
			."\"money\": \"".$money."\","
			."\"anonChance\": \"".$anonChance."\","
			."\"rep_change\": \"".$rep_change."\","
			."\"id\": \"".$row['id']."\","
			."\"ip\": \"".long2ip($ip)."\"}";
		}						
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>