<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare('SELECT user.*,items.*,crew.name,skill_tree.new_lvl_collected,skill_tree.skill_points,skill_tree.lvl,skill_tree.xp,player_profile.pic,feedback.answer1,feedback.answer2,TIMESTAMPDIFF(DAY,feedback.timestamp1,NOW()) as feedback1t FROM items JOIN user ON user.id=items.user_id JOIN player_profile ON user.id=player_profile.user_id JOIN skill_tree ON user.id=skill_tree.user_id JOIN feedback ON user.id=feedback.user_id LEFT JOIN crew ON user.crew=crew.id WHERE user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$packs = $row['small_packs']+$row['medium_packs']+$row['large_packs']+$row['small_money']+$row['medium_money']+$row['large_money']+$row['small_oc_packs']+$row['medium_oc_packs']+$row['large_oc_packs'];

			//Level and XP
			$xp=$row['xp'];
			$lvl = $row['lvl'];
			$base_xp=sommatoria($lvl);
			$next_lvl=sommatoria($lvl+1);
			
			$score=$row['score'];
			$answer1=$row['answer1'];
			$answer2=$row['answer2'];
			$feedback1t=$row['feedback1t'];
			
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"score\": \"".$row['score']."\",\n"
			."\"ip\": \"".long2ip($row['ip'])."\",\n"
			."\"reputation\": \"".$row['missions_rep']."\",\n"
			."\"packs\": ".$packs.",\n"	
			."\"pic\": ".$row['pic'].",\n"	
			."\"lvl\": ".$lvl.",\n"
			."\"xp\": ".$xp.",\n"
			."\"skill_points\": ".$row['skill_points'].",\n"
			."\"base_xp\": ".$base_xp.",\n"
			."\"next_lvl\": ".$next_lvl.",\n"
			."\"cryptocoins\": ".$row['cryptocoins'].",\n"		
			."\"overclock\": ".$row['overclock'].",\n"	
			."\"gc_role\": ".$row['gc_role'].",\n"
			."\"new_lvl\": ".$row['new_lvl_collected'].",\n"
			."\"money\": ".$row['money'].",\n";			
			if ($row['crew'] != 0) { 
				$resp = $resp."\"crew\": \"Y\",\n\"crew_name\": \"".$row['name']."\",\n"; 
				$crew=true;
				$my_crew=$row['crew'];
			}
			else { 
				$resp = $resp."\"crew\": \"N\",\n"; 
				$crew=false;
			}
		}
		//Messages
		$stmt = $db->prepare('SELECT count(id) as new_msg FROM `private_chat` WHERE (uuid2=(SELECT uuid FROM user WHERE id=?)) and seen=0');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$new_msg=$row['new_msg'];			
		}		
		$stmt = $db->prepare('SELECT count(id) as new_req FROM msg_request WHERE msg_request.dst=(SELECT uuid FROM user WHERE id=?)');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$new_msg = $new_msg+$row['new_req'];
			$resp = $resp."\"new_msg\": \"".$new_msg."\",\n";			
		}		
		//Task
		$stmt = $db->prepare('SELECT count(task_id) as task_n FROM `task` WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"task_n\": \"".$row['task_n']."\",\n";			
		}		
		//Missions
		$stmt = $db->prepare('SELECT count(id) as mission_n FROM `missions_available` WHERE user_id=? and time_finish<NOW() and running=1');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"mission_n\": \"".$row['mission_n']."\",\n";			
		}	
		//Attack Received
		$stmt = $db->prepare('SELECT count(id) as log_n FROM (SELECT * FROM attack_log where attacker_id=? or defense_id=? ORDER BY timestamp DESC LIMIT 20) as t WHERE t.defense_id=? and t.seen=0');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"log_n\": \"".$row['log_n']."\",\n";			
		}	
		//Tournament
		$stmt = $db->prepare('SELECT tournaments.type FROM `tournaments` WHERE CURTIME()<time_end ORDER BY time_end LIMIT 1');
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"tournament\": \"".$row['type']."\",\n";			
		}		
		//Crew Invitations
		if ($crew==false) {
			$stmt = $db->prepare('SELECT count(id) as invitations FROM crew_invitation WHERE user_id=?');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$resp = $resp."\"invitations\": \"".$row['invitations']."\",\n";			
			}	
		} else {
			$stmt = $db->prepare('SELECT count(crew_id) as requests FROM crew_requests WHERE crew_id=(SELECT crew FROM user WHERE id=?)');
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$resp = $resp."\"requests\": \"".$row['requests']."\",\n";			
			}	
		}
		//Crew Messages & Logs
		$stmt = $db->prepare('SELECT count(id) as msgs FROM crew_chat WHERE crew_id=? and user_id<>0 and timestamp>(SELECT crew_chat_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"crew_chats\": ".$row['msgs'].",\n";
		}	
		$stmt = $db->prepare('SELECT count(id) as count FROM `datacenter_attack_logs` WHERE (attacking_crew=? or datacenter_id=(SELECT id FROM datacenter WHERE crew_id=?)) and attack_status=3 and result=1 and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countWar=$row['count'];
		}	
		$stmt = $db->prepare('SELECT count(id) as count FROM crew_logs WHERE crew_id=? and timestamp>(SELECT crew_log_timestamp FROM user WHERE id=?)');
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countEvents=$row['count'];
		}	
		$resp = $resp."\"crew_logs\": ".($countWar+$countEvents).",\n";
		
		//Activity
		$stmt = $db->prepare('SELECT today_activity,current_activity,today_reward FROM user_stats WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$today_reward = $row['today_reward'];
			$today_activity = $row['today_activity'];
			$current_activity = $row['current_activity'];
			if ($today_activity == 0) {
				$stmt = $db->prepare('UPDATE user_stats SET today_activity=1,current_activity=current_activity+1 WHERE id=? and today_activity=0');
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->execute();
				$stmt = $db->prepare('UPDATE user_stats SET max_activity=current_activity WHERE id=? and max_activity<current_activity');
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->execute();
				$current_activity=$current_activity+1;
			}
			$resp = $resp."\"today_reward\": \"".$today_reward."\",\n";	
			$resp = $resp."\"current_activity\": \"".$current_activity."\",\n";					
		}		
		
		//In-Game Feedback
		if (($answer1==0) and ($score>500)) {
			$resp = $resp."\"question\": \"Q1\",\n";	
		}
		elseif (($answer2==0) and ($score>5000) and ($current_activity>=5) and ($feedback1t>3)) {
			$resp = $resp."\"question\": \"Q2\",\n";
		}
		else {
			$resp = $resp."\"question\": \"N\",\n";
		}
		
		//Get Achievement Current Level
		$stmt = $db->prepare("SELECT * FROM achievement WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$internet_a = $row['internet'];
			$cpu_a = $row['cpu'];
			$c2c_a = $row['c2c'];
			$ram_a = $row['ram'];
			$hdd_a = $row['hdd'];
			$fan_a = $row['fan'];
			$gpu_a = $row['gpu'];
			$firewall_a = $row['firewall'];
			$ips_a = $row['ips'];
			$av_a = $row['av'];
			$malware_a = $row['malware'];
			$exploit_a = $row['exploit'];
			$siem_a = $row['siem'];
			$anon_a = $row['anon'];
			$webs_a = $row['webs'];
			$apps_a = $row['apps'];
			$dbs_a = $row['dbs'];
			$scan_a = $row['scan'];
			$attack_w_a = $row['attack_w'];
			$missions_a = $row['missions'];
			$logins_a = $row['max_activity'];
			$loyal_a = $row['loyal'];
		}
				
		//Get Upgrades Level
		$stmt = $db->prepare("SELECT * FROM upgrades WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$internet = $row['internet'];
			$cpu = $row['cpu'];
			$c2c = $row['c2c'];
			$ram = $row['ram'];
			$hdd = $row['hdd'];
			$fan = $row['fan'];
			$gpu = $row['gpu'];
			$firewall = $row['firewall'];
			$ips = $row['ips'];
			$av = $row['av'];
			$malware = $row['malware'];
			$exploit = $row['exploit'];
			$siem = $row['siem'];
			$anon = $row['anon'];
			$webs = $row['webs'];
			$apps = $row['apps'];
			$dbs = $row['dbs'];
			$scan = $row['scan'];
		}		
		//Get Stats
		$stmt = $db->prepare("SELECT attack_w,max_activity,missions,videos,TIMESTAMPDIFF(DAY,user.creation_time,NOW()) AS loyal FROM user_stats JOIN user ON user_stats.id=user.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$attack_w = $row['attack_w'];
			$missions = $row['missions'];
			$logins = $row['max_activity'];
			$loyal = $row['loyal'];
		}		
		
		//Get Next Achievement
		$internet_next = getNextLevel('internet',$internet_a);
		$cpu_next = getNextLevel('cpu',$cpu_a);
		$c2c_next = getNextLevel('c2c',$c2c_a);
		$ram_next = getNextLevel('ram',$ram_a);
		$hdd_next = getNextLevel('hdd',$hdd_a);
		$fan_next = getNextLevel('fan',$fan_a);
		$gpu_next = getNextLevel('gpu',$gpu_a);
		$firewall_next = getNextLevel('firewall',$firewall_a);
		$ips_next = getNextLevel('ips',$ips_a);
		$av_next = getNextLevel('av',$av_a);
		$malware_next = getNextLevel('malware',$malware_a);
		$exploit_next = getNextLevel('exploit',$exploit_a);
		$siem_next = getNextLevel('siem',$siem_a);
		$anon_next = getNextLevel('anon',$anon_a);
		$webs_next = getNextLevel('webs',$webs_a);
		$apps_next = getNextLevel('apps',$apps_a);
		$dbs_next = getNextLevel('dbs',$dbs_a);
		$scan_next = getNextLevel('scan',$scan_a);
		$attack_w_next = getNextLevel('attack_w',$attack_w_a);
		$missions_next = getNextLevel('missions',$missions_a);
		$logins_next = getNextLevel('max_activity',$logins_a);
		$loyal_next = getNextLevel('loyal',$loyal_a);
		
		//Previous not collected
		$achievementCount=0;
		if ($internet>=$internet_next) { $achievementCount++; }
		if ($cpu>=$cpu_next) { $achievementCount++; }
		if ($c2c>=$c2c_next) { $achievementCount++; }
		if ($ram>=$ram_next) { $achievementCount++; }
		if ($hdd>=$hdd_next) { $achievementCount++; }
		if ($fan>=$fan_next) { $achievementCount++; }
		if (($gpu>=$gpu_next) and ($gpu_next<10001)) { $achievementCount++; }
		if (($firewall>=$firewall_next) and ($firewall_next<10001)) { $achievementCount++; }
		if (($ips>=$ips_next) and ($ips_next<10001)) { $achievementCount++; }
		if (($av>=$av_next) and ($av_next<10001)) { $achievementCount++; }
		if (($malware>=$malware_next) and ($malware_next<10001)) { $achievementCount++; }
		if (($exploit>=$exploit_next) and ($exploit_next<10001)) { $achievementCount++; }
		if (($siem>=$siem_next) and ($siem_next<10001)) { $achievementCount++; }
		if (($anon>=$anon_next) and ($anon_next<10001)) { $achievementCount++; }
		if (($webs>=$webs_next) and ($webs_next<10001)) { $achievementCount++; }
		if (($apps>=$apps_next) and ($apps_next<10001)) { $achievementCount++; }
		if (($dbs>=$dbs_next) and ($dbs_next<10001)) { $achievementCount++; }
		if (($scan>=$scan_next) and ($scan_next<10001)) { $achievementCount++; }
		if (($attack_w>=$attack_w_next) and ($attack_w_next<10001)) { $achievementCount++; }
		if (($missions>=$missions_next) and ($missions_next<5001)) { $achievementCount++; }
		if (($logins>=$logins_next) and ($logins_next<61)) { $achievementCount++; }
		if (($loyal>=$loyal_next) and ($loyal_next<366)) { $achievementCount++; }
		$resp = $resp."\"achievements\": ".$achievementCount.",\n";	
		
		//Rank
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT rank FROM (SELECT id, username, score, @curRank := @curRank + 1 AS rank FROM user ORDER BY score DESC) as t WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$db->commit();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"rank\": \"".$row['rank']."\",\n";			
		}		
		
		$resp = $resp."}";
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>