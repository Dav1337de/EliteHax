<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare('SELECT upgrades.*,user.username,user.money,skill_tree.st_upgrade_cost,skill_tree.st_upgrade_speed,research.* FROM upgrades JOIN user ON upgrades.id=user.id JOIN skill_tree ON user.id=skill_tree.user_id JOIN research ON user.id=research.user_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$st_upgrade_cost = $row['st_upgrade_cost'];
			$st_upgrade_speed = $row['st_upgrade_speed'];
			$upgradeR1 = $row['upgradeR1'];
			$upgradeR2 = $row['upgradeR2'];
			$internet_cost = getMoney("internet",$row['internet_task']+1);
			$internet_cost = $internet_cost-($internet_cost/100*(2*$st_upgrade_cost));
			$internet_cost = $internet_cost-($internet_cost/100*(0.2*$upgradeR1));
			$internet_time_temp = getTime("internet",$row['internet_task']+1,$row['internet'],$row['cpu']);
			$internet_time = $internet_time_temp[2];
			if ($st_upgrade_speed>0) { $internet_time=$internet_time-round($internet_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $internet_time=$internet_time-round($internet_time/100*($upgradeR2*0.2)); }
			$siem_cost = getMoney("siem",$row['siem_task']+1);
			$siem_cost = $siem_cost-($siem_cost/100*(2*$st_upgrade_cost));
			$siem_cost = $siem_cost-($siem_cost/100*(0.2*$upgradeR1));
			$siem_time_temp = getTime("siem",$row['siem_task']+1,$row['internet'],$row['cpu']);
			$siem_time = $siem_time_temp[2];
			$siem_r = $row['siem_task']+round(($row['siem_task']/100*(0.1*$row['siemR1']))+($row['siem_task']/100*(0.2*$row['siemR2'])));
			if ($st_upgrade_speed>0) { $siem_time=$siem_time-round($siem_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $siem_time=$siem_time-round($siem_time/100*($upgradeR2*0.2)); }
			$firewall_cost = getMoney("firewall",$row['firewall_task']+1);
			$firewall_cost = $firewall_cost-($firewall_cost/100*(2*$st_upgrade_cost));
			$firewall_cost = $firewall_cost-($firewall_cost/100*(0.2*$upgradeR1));
			$firewall_time_temp = getTime("firewall",$row['firewall_task']+1,$row['internet'],$row['cpu']);
			$firewall_time = $firewall_time_temp[2];
			$firewall_r = $row['firewall_task']+round(($row['firewall_task']/100*(0.1*$row['fwR1']))+($row['firewall_task']/100*(0.2*$row['fwR2'])));
			if ($st_upgrade_speed>0) { $firewall_time=$firewall_time-round($firewall_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $firewall_time=$firewall_time-round($firewall_time/100*($upgradeR2*0.2)); }
			$ips_cost = getMoney("ips",$row['ips_task']+1);
			$ips_cost = $ips_cost-($ips_cost/100*(2*$st_upgrade_cost));
			$ips_cost = $ips_cost-($ips_cost/100*(0.2*$upgradeR1));
			$ips_time_temp = getTime("ips",$row['ips_task']+1,$row['internet'],$row['cpu']);
			$ips_time = $ips_time_temp[2];
			$ips_r = $row['ips_task']+round(($row['ips_task']/100*(0.1*$row['ipsR1']))+($row['ips_task']/100*(0.2*$row['ipsR2'])));
			if ($st_upgrade_speed>0) { $ips_time=$ips_time-round($ips_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $ips_time=$ips_time-round($ips_time/100*($upgradeR2*0.2)); }
			$c2c_cost = getMoney("c2c",$row['c2c_task']+1);
			$c2c_cost = $c2c_cost-($c2c_cost/100*(2*$st_upgrade_cost));
			$c2c_cost = $c2c_cost-($c2c_cost/100*(0.2*$upgradeR1));
			$c2c_time_temp = getTime("c2c",$row['c2c_task']+1,$row['internet'],$row['cpu']);
			$c2c_time = $c2c_time_temp[2];
			if ($st_upgrade_speed>0) { $c2c_time=$c2c_time-round($c2c_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $c2c_time=$c2c_time-round($c2c_time/100*($upgradeR2*0.2)); }
			$anon_cost = getMoney("anon",$row['anon_task']+1);
			$anon_cost = $anon_cost-($anon_cost/100*(2*$st_upgrade_cost));
			$anon_cost = $anon_cost-($anon_cost/100*(0.2*$upgradeR1));
			$anon_time_temp = getTime("anon",$row['anon_task']+1,$row['internet'],$row['cpu']);
			$anon_time = $anon_time_temp[2];
			$anon_r = $row['anon_task']+round(($row['anon_task']/100*(0.1*$row['anonR1']))+($row['anon_task']/100*(0.2*$row['anonR2'])));
			if ($st_upgrade_speed>0) { $anon_time=$anon_time-round($anon_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $anon_time=$anon_time-round($anon_time/100*($upgradeR2*0.2)); }
			$webs_cost = getMoney("webs",$row['webs_task']+1);
			$webs_cost = $webs_cost-($webs_cost/100*(2*$st_upgrade_cost));
			$webs_cost = $webs_cost-($webs_cost/100*(0.2*$upgradeR1));
			$webs_time_temp = getTime("webs",$row['webs_task']+1,$row['internet'],$row['cpu']);
			$webs_time = $webs_time_temp[2];
			$webs_r = $row['webs_task']+round(($row['webs_task']/100*(0.1*$row['progR1']))+($row['webs_task']/100*(0.2*$row['progR2'])));
			if ($st_upgrade_speed>0) { $webs_time=$webs_time-round($webs_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $webs_time=$webs_time-round($webs_time/100*($upgradeR2*0.2)); }
			$apps_cost = getMoney("apps",$row['apps_task']+1);
			$apps_cost = $apps_cost-($apps_cost/100*(2*$st_upgrade_cost));
			$apps_cost = $apps_cost-($apps_cost/100*(0.2*$upgradeR1));
			$apps_time_temp = getTime("apps",$row['apps_task']+1,$row['internet'],$row['cpu']);
			$apps_time = $apps_time_temp[2];
			$apps_r = $row['apps_task']+round(($row['apps_task']/100*(0.1*$row['progR1']))+($row['apps_task']/100*(0.2*$row['progR2'])));
			if ($st_upgrade_speed>0) { $apps_time=$apps_time-round($apps_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $apps_time=$apps_time-round($apps_time/100*($upgradeR2*0.2)); }
			$dbs_cost = getMoney("dbs",$row['dbs_task']+1);
			$dbs_cost = $dbs_cost-($dbs_cost/100*(2*$st_upgrade_cost));
			$dbs_cost = $dbs_cost-($dbs_cost/100*(0.2*$upgradeR1));
			$dbs_time_temp = getTime("dbs",$row['dbs_task']+1,$row['internet'],$row['cpu']);
			$dbs_time = $dbs_time_temp[2];
			$dbs_r = $row['dbs_task']+round(($row['dbs_task']/100*(0.1*$row['progR1']))+($row['dbs_task']/100*(0.2*$row['progR2'])));
			if ($st_upgrade_speed>0) { $dbs_time=$dbs_time-round($dbs_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $dbs_time=$dbs_time-round($dbs_time/100*($upgradeR2*0.2)); }
			$cpu_cost = getMoney("cpu",$row['cpu_task']+1);
			$cpu_cost = $cpu_cost-($cpu_cost/100*(2*$st_upgrade_cost));
			$cpu_cost = $cpu_cost-($cpu_cost/100*(0.2*$upgradeR1));
			$cpu_time_temp = getTime("cpu",$row['cpu_task']+1,$row['internet'],$row['cpu']);
			$cpu_time = $cpu_time_temp[2];
			if ($st_upgrade_speed>0) { $cpu_time=$cpu_time-round($cpu_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $cpu_time=$cpu_time-round($cpu_time/100*($upgradeR2*0.2)); }
			$ram_cost = getMoney("ram",$row['ram_task']+1);
			$ram_cost = $ram_cost-($ram_cost/100*(2*$st_upgrade_cost));
			$ram_cost = $ram_cost-($ram_cost/100*(0.2*$upgradeR1));
			$ram_time_temp = getTime("ram",$row['ram_task']+1,$row['internet'],$row['cpu']);
			$ram_time = $ram_time_temp[2];
			if ($st_upgrade_speed>0) { $ram_time=$ram_time-round($ram_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $ram_time=$ram_time-round($ram_time/100*($upgradeR2*0.2)); }
			$hdd_cost = getMoney("hdd",$row['hdd_task']+1);
			$hdd_cost = $hdd_cost-($hdd_cost/100*(2*$st_upgrade_cost));
			$hdd_cost = $hdd_cost-($hdd_cost/100*(0.2*$upgradeR1));
			$hdd_time_temp = getTime("hdd",$row['hdd_task']+1,$row['internet'],$row['cpu']);
			$hdd_time = $hdd_time_temp[2];
			if ($st_upgrade_speed>0) { $hdd_time=$hdd_time-round($hdd_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $hdd_time=$hdd_time-round($hdd_time/100*($upgradeR2*0.2)); }
			$gpu_cost = getMoney("gpu",$row['gpu_task']+1);
			$gpu_cost = $gpu_cost-($gpu_cost/100*(2*$st_upgrade_cost));
			$gpu_cost = $gpu_cost-($gpu_cost/100*(0.2*$upgradeR1));
			$gpu_time_temp = getTime("gpu",$row['gpu_task']+1,$row['internet'],$row['cpu']);
			$gpu_time = $gpu_time_temp[2];
			if ($st_upgrade_speed>0) { $gpu_time=$gpu_time-round($gpu_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $gpu_time=$gpu_time-round($gpu_time/100*($upgradeR2*0.2)); }
			$fan_cost = getMoney("fan",$row['fan_task']+1);
			$fan_cost = $fan_cost-($fan_cost/100*(2*$st_upgrade_cost));
			$fan_cost = $fan_cost-($fan_cost/100*(0.2*$upgradeR1));
			$fan_time_temp = getTime("fan",$row['fan_task']+1,$row['internet'],$row['cpu']);
			$fan_time = $fan_time_temp[2];
			if ($st_upgrade_speed>0) { $fan_time=$fan_time-round($fan_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $fan_time=$fan_time-round($fan_time/100*($upgradeR2*0.2)); }
			$cryptominer_cost = getMoney("cryptominer",$row['cryptominer_task']+1);
			$cryptominer_cost = $cryptominer_cost-($cryptominer_cost/100*(2*$st_upgrade_cost));
			$cryptominer_cost = $cryptominer_cost-($cryptominer_cost/100*(0.2*$upgradeR1));
			$cryptominer_time_temp = getTime("cryptominer",$row['cryptominer_task']+1,$row['internet'],$row['cpu']);
			$cryptominer_time = $cryptominer_time_temp[2];
			if ($st_upgrade_speed>0) { $cryptominer_time=$cryptominer_time-round($cryptominer_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $cryptominer_time=$cryptominer_time-round($cryptominer_time/100*($upgradeR2*0.2)); }				
			$av_cost = getMoney("av",$row['av_task']+1);
			$av_cost = $av_cost-($av_cost/100*(2*$st_upgrade_cost));
			$av_cost = $av_cost-($av_cost/100*(0.2*$upgradeR1));
			$av_time_temp = getTime("av",$row['av_task']+1,$row['internet'],$row['cpu']);
			$av_time = $av_time_temp[2];
			$av_r = $row['av_task']+round(($row['av_task']/100*(0.1*$row['avR1']))+($row['av_task']/100*(0.2*$row['avR2'])));
			if ($st_upgrade_speed>0) { $av_time=$av_time-round($av_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $av_time=$av_time-round($av_time/100*($upgradeR2*0.2)); }
			$malware_cost = getMoney("malware",$row['malware_task']+1);
			$malware_cost = $malware_cost-($malware_cost/100*(2*$st_upgrade_cost));
			$malware_cost = $malware_cost-($malware_cost/100*(0.2*$upgradeR1));
			$malware_time_temp = getTime("malware",$row['malware_task']+1,$row['internet'],$row['cpu']);
			$malware_time = $malware_time_temp[2];
			$malware_r = $row['malware_task']+round(($row['malware_task']/100*(0.1*$row['malwareR1']))+($row['malware_task']/100*(0.2*$row['malwareR2'])));
			if ($st_upgrade_speed>0) { $malware_time=$malware_time-round($malware_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $malware_time=$malware_time-round($malware_time/100*($upgradeR2*0.2)); }
			$scan_cost = getMoney("scan",$row['scan_task']+1);
			$scan_cost = $scan_cost-($scan_cost/100*(2*$st_upgrade_cost));
			$scan_cost = $scan_cost-($scan_cost/100*(0.2*$upgradeR1));
			$scan_time_temp = getTime("scan",$row['scan_task']+1,$row['internet'],$row['cpu']);
			$scan_time = $scan_time_temp[2];
			$scan_r = $row['scan_task']+round(($row['scan_task']/100*(0.1*$row['scannerR1']))+($row['scan_task']/100*(0.2*$row['scannerR2'])));
			if ($st_upgrade_speed>0) { $scan_time=$scan_time-round($scan_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $scan_time=$scan_time-round($scan_time/100*($upgradeR2*0.2)); }
			$exploit_cost = getMoney("exploit",$row['exploit_task']+1);
			$exploit_cost = $exploit_cost-($exploit_cost/100*(2*$st_upgrade_cost));
			$exploit_cost = $exploit_cost-($exploit_cost/100*(0.2*$upgradeR1));
			$exploit_time_temp = getTime("exploit",$row['exploit_task']+1,$row['internet'],$row['cpu']);
			$exploit_time = $exploit_time_temp[2];
			$exploit_r = $row['exploit_task']+round(($row['exploit_task']/100*(0.1*$row['exploitR1']))+($row['exploit_task']/100*(0.2*$row['exploitR2'])));
			if ($st_upgrade_speed>0) { $exploit_time=$exploit_time-round($exploit_time/100*($st_upgrade_speed*2)); }
			if ($upgradeR2>0) { $exploit_time=$exploit_time-round($exploit_time/100*($upgradeR2*0.2)); }
					
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"internet\": ".$row['internet_task'].",\n"
			."\"internet_r\": 0,\n"
			."\"internet_cost\": ".round($internet_cost).",\n"
			."\"internet_time\": ".$internet_time.",\n"
			."\"siem\": ".$row['siem_task'].",\n"
			."\"siem_r\": ".$siem_r.",\n"
			."\"siem_cost\": ".round($siem_cost).",\n"
			."\"siem_time\": ".$siem_time.",\n"
			."\"firewall\": ".$row['firewall_task'].",\n"
			."\"firewall_r\": ".$firewall_r.",\n"
			."\"firewall_cost\": ".round($firewall_cost).",\n"
			."\"firewall_time\": ".$firewall_time.",\n"
			."\"ips\": ".$row['ips_task'].",\n"
			."\"ips_r\": ".$ips_r.",\n"
			."\"ips_cost\": ".round($ips_cost).",\n"
			."\"ips_time\": ".$ips_time.",\n"
			."\"c2c\": ".$row['c2c_task'].",\n"
			."\"c2c_r\": 0,\n"
			."\"c2c_cost\": ".round($c2c_cost).",\n"
			."\"c2c_time\": ".$c2c_time.",\n"
			."\"anon\": ".$row['anon_task'].",\n"
			."\"anon_r\": ".$anon_r.",\n"
			."\"anon_cost\": ".round($anon_cost).",\n"
			."\"anon_time\": ".$anon_time.",\n"
			."\"webs\": ".$row['webs_task'].",\n"
			."\"webs_r\": ".$webs_r.",\n"
			."\"webs_cost\": ".round($webs_cost).",\n"
			."\"webs_time\": ".$webs_time.",\n"
			."\"apps\": ".$row['apps_task'].",\n"
			."\"apps_r\": ".$apps_r.",\n"
			."\"apps_cost\": ".round($apps_cost).",\n"
			."\"apps_time\": ".$apps_time.",\n"
			."\"dbs\": ".$row['dbs_task'].",\n"
			."\"dbs_r\": ".$dbs_r.",\n"
			."\"dbs_cost\": ".round($dbs_cost).",\n"
			."\"dbs_time\": ".$dbs_time.",\n"
			."\"cpu\": ".$row['cpu_task'].",\n"
			."\"cpu_r\": 0,\n"
			."\"cpu_cost\": ".round($cpu_cost).",\n"
			."\"cpu_time\": ".$cpu_time.",\n"
			."\"ram\": ".$row['ram_task'].",\n"
			."\"ram_r\": 0,\n"
			."\"ram_cost\": ".round($ram_cost).",\n"
			."\"ram_time\": ".$ram_time.",\n"
			."\"hdd\": ".$row['hdd_task'].",\n"
			."\"hdd_r\": 0,\n"
			."\"hdd_cost\": ".round($hdd_cost).",\n"
			."\"hdd_time\": ".$hdd_time.",\n"
			."\"gpu\": ".$row['gpu_task'].",\n"
			."\"gpu_r\": 0,\n"
			."\"gpu_cost\": ".round($gpu_cost).",\n"
			."\"gpu_time\": ".$gpu_time.",\n"
			."\"fan\": ".$row['fan_task'].",\n"
			."\"fan_r\": 0,\n"
			."\"fan_cost\": ".round($fan_cost).",\n"
			."\"fan_time\": ".$fan_time.",\n"
			."\"cryptominer\": ".$row['cryptominer_task'].",\n"
			."\"cryptominer_r\": 0,\n"
			."\"cryptominer_cost\": ".round($cryptominer_cost).",\n"
			."\"cryptominer_time\": ".$cryptominer_time.",\n"
			."\"av\": ".$row['av_task'].",\n"
			."\"av_r\": ".$av_r.",\n"
			."\"av_cost\": ".round($av_cost).",\n"
			."\"av_time\": ".$av_time.",\n"
			."\"malware\": ".$row['malware_task'].",\n"
			."\"malware_r\": ".$malware_r.",\n"
			."\"malware_cost\": ".round($malware_cost).",\n"
			."\"malware_time\": ".$malware_time.",\n"
			."\"scan\": ".$row['scan_task'].",\n"
			."\"scan_r\": ".$scan_r.",\n"
			."\"scan_cost\": ".round($scan_cost).",\n"
			."\"scan_time\": ".$scan_time.",\n"
			."\"exploit_cost\": ".round($exploit_cost).",\n"
			."\"exploit_time\": ".$exploit_time.",\n"
			."\"exploit_r\": ".$exploit_r.",\n"
			."\"exploit\": ".$row['exploit_task']."\n}";
			echo base64_encode($resp);
			//echo "<p>".$resp;
		}
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>