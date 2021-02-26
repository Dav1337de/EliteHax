<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$checkNonce=checkNonce($db,$id);
		if ($checkNonce!=true) { exit("Nonce Issue"); }
		
		$stmt = $db->prepare("SELECT user.crew,upgrades.scan,upgrades.malware,upgrades.exploit,upgrades.anon,user.reputation,skill_tree.st_pentester,skill_tree.st_pentester2,skill_tree.st_stealth,skill_tree.st_bank_exp,research.scannerR1,research.scannerR2,research.anonR1,research.anonR2,research.exploitR1,research.exploitR2,research.malwareR1,research.malwareR2 FROM upgrades JOIN user ON upgrades.id = user.id JOIN skill_tree ON user.id=skill_tree.user_id JOIN research ON user.id=research.user_id where user.id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$my_crew = $row['crew'];
			$my_scan = $row['scan'];
			$my_malware = $row['malware'];
			$my_exploit = $row['exploit'];
			$my_anon = $row['anon'];
			$my_rep = $row['reputation'];
			$st_pentester1 = $row['st_pentester'];
			$st_pentester2 = $row['st_pentester2'];
			$st_stealth = $row['st_stealth'];
			$st_bank_exp = $row['st_bank_exp'];
			$my_scannerR1 = $row['scannerR1'];
			$my_scannerR2 = $row['scannerR2'];
			$my_anonR1 = $row['anonR1'];
			$my_anonR2 = $row['anonR2'];
			$my_exploitR1 = $row['exploitR1'];
			$my_exploitR2 = $row['exploitR2'];
			$my_malwareR1 = $row['malwareR1'];
			$my_malwareR2 = $row['malwareR2'];
		}
		
		$attacked="N";
		$stmt = $db->prepare("SELECT timestamp, DATE_ADD(timestamp,INTERVAL 60 MINUTE) as next_attack FROM attack_log JOIN user ON attack_log.defense_id = user.id WHERE attacker_id=? and uuid=? and DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['target'], PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) { 
			$attacked="Y";
		}
		$stmt = $db->prepare("SELECT upgrades.*,user.crew,user.username,user.ip,user.money,user.reputation,crew.tag,skill_tree.st_dev1,skill_tree.st_dev2,skill_tree.st_analyst,skill_tree.st_safe_pay,research.fwR1,research.fwR2,research.siemR1,research.siemR2,research.ipsR1,research.ipsR2,research.avR1,research.avR2,research.progR1,research.progR2,research.exploitR1,research.exploitR2,research.malwareR1,research.malwareR2 FROM upgrades JOIN user ON upgrades.id = user.id JOIN skill_tree on upgrades.id = skill_tree.user_id JOIN research ON user.id=research.user_id LEFT JOIN crew ON user.crew = crew.id where user.uuid=?");
		$stmt->bindValue(1, $_POST['target'], PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$target_crew = $row['crew'];
			$user = $row['username'];
			$ip = $row['ip'];
			$rep = $row['reputation'];
			$firewall = $row['firewall'];
			$ips = $row['ips'];
			$webs = $row['webs'];
			$apps = $row['apps'];
			$dbs = $row['dbs'];
			$av = $row['av'];
			$siem = $row['siem'];
			$malware = $row['malware'];
			$exploit = $row['exploit'];
			$st_dev1 = $row['st_dev1'];
			$st_dev2 = $row['st_dev2'];
			$st_analyst = $row['st_analyst'];
			$st_safe_pay = $row['st_safe_pay'];
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
			$exploitR1 = $row['exploitR1'];
			$exploitR2 = $row['exploitR2'];
			$malwareR1 = $row['malwareR1'];
			$malwareR2 = $row['malwareR2'];
			
			//Research Contribution
			//Offensive
			$my_scan=$my_scan+round(($my_scan/100*(0.1*$my_scannerR1))+($my_scan/100*(0.2*$my_scannerR2)));
			$my_exploit=$my_exploit+round(($my_exploit/100*(0.1*$my_exploitR1))+($my_exploit/100*(0.2*$my_exploitR2)));
			$my_malware=$my_malware+round(($my_malware/100*(0.1*$my_malwareR1))+($my_malware/100*(0.2*$my_malwareR2)));
			$my_anon=$my_anon+round(($my_anon/100*(0.1*$my_anonR1))+($my_anon/100*(0.2*$my_anonR2)));
			//Defensive
			$firewall=$firewall+round(($firewall/100*(0.1*$fwR1))+($firewall/100*(0.2*$fwR2)));
			$ips_c=$ips+round(($ips/100*(0.1*$ipsR1))+($ips/100*(0.2*$ipsR2)));
			$webs_c=$webs+round(($webs/100*(0.1*$progR1))+($webs/100*(0.2*$progR2)));
			$apps_c=$apps+round(($apps/100*(0.1*$progR1))+($apps/100*(0.2*$progR2)));
			$dbs_c=$dbs+round(($dbs/100*(0.1*$progR1))+($dbs/100*(0.2*$progR2)));
			$av_c=$av+round(($av/100*(0.1*$avR1))+($av/100*(0.2*$avR2)));
			$siem_c=$siem+round(($siem/100*(0.1*$siemR1))+($siem/100*(0.2*$siemR2)));
			$malware_c=$malware+round(($malware/100*(0.1*$malwareR1))+($malware/100*(0.2*$malwareR2)));
			$exploit_c=$exploit+round(($exploit/100*(0.1*$exploitR1))+($exploit/100*(0.2*$exploitR2)));
			
			//SCAN SETTINGS
			$safemoney = pow(2,(4+$row['hdd']))*1000;
			$money=$row['money']-$safemoney;
			if ($money<0) { $money=0; }
			if ($my_scan >= $firewall*1.3) { $user = $row['username']; } else $user = "?";
			if ($my_scan >= $firewall*1.5) { $crew = $row['tag']; } else $crew = "?";
			if ($crew == "") { $crew = "None"; }
			if ($my_crew == $target_crew) { $crew = $row['tag']; }
			if ($my_scan >= $firewall*0.8) { $ips = $ips_c; } else $ips = "?";
			if ($my_scan >= $firewall*0.8) { $webs = $webs_c; } else $webs = "?";
			if ($my_scan >= $firewall) { $apps = $apps_c; } else $apps = "?";
			if ($my_scan >= $firewall*1.2) { $dbs = $dbs_c; } else $dbs = "?";
			if ($my_scan >= $firewall) { $av = $av_c; } else $av = "?";
			if ($my_scan >= $firewall*1.3) { $gpu = $row['gpu']; } else $gpu = "?";
			if ($my_scan >= $firewall*1.3) { $malware = $malware_c; } else $malware = "?";
			if ($my_scan >= $firewall*1.3) { $exploit = $exploit_c; } else $exploit = "?";
			if ($my_scan >= $firewall*1.3) { $money = $money; } else $money = "?";
			//SUCCESS CHANCE SETTINGS
			$webChance = floor(($my_exploit*90)/($ips_c+$webs_c)); 
			$appChance = floor(($my_exploit*60)/($ips_c+$apps_c));
			$dbChance = floor(($my_exploit*30)/($ips_c+$dbs_c));
			$moneyChance = floor(($my_malware*50)/($av_c));
			$botChance = floor(($my_malware*50)/($av_c));
			$ratChance = floor(($my_malware*30)/($av_c));
			$anonChance = floor(($my_anon*100)/($firewall+($siem_c/5)));
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
			."\"attacked\": \"".$attacked."\","
			."\"firewall\": \"".$firewall."\","
			."\"ips\": \"".$ips."\","
			."\"webs\": \"".$webs."\","
			."\"apps\": \"".$apps."\","
			."\"dbs\": \"".$dbs."\","
			."\"av\": \"".$av."\","
			."\"gpu\": \"".$gpu."\","
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
			."\"ip\": \"".long2ip($ip)."\"}";
		}						
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>