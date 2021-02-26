<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['player_id']))
		exit("");
	$username=$_POST['player_id'];
	try {
		$id = getIdFromToken($db);
		//Check Existing Username
		$stmt = $db->prepare("SELECT id,uuid FROM user WHERE username=?"); 
		$stmt->bindValue(1, $username, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { 
			exit("");		
		}	
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$player_id=$row['id'];
			$player_uuid=$row['uuid'];
		}	
		
		//Supporter
		$stmt = $db->prepare("SELECT supporter.*,DATEDIFF(end_date,NOW()) as days_left FROM supporter WHERE user_id=? order by id desc limit 1"); 
		$stmt->bindValue(1, $player_id, PDO::PARAM_INT);
		$stmt->execute();
		
		$bronze=0;
		$silver=0;
		$gold=0;
			
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['type']=="supporter_bronze") { $bronze=$row['days_left']; }
			elseif ($row['type']=="supporter_silver") { $silver=$row['days_left']; }
			elseif ($row['type']=="supporter_gold") { $gold=$row['days_left']; }
		}
		
		//Badges
		$stmt = $db->prepare('SELECT user.username,items_pay.supporter1,items_pay.supporter2,items_pay.supporter3,user.gc_role,player_profile.skin,player_profile.pic,crew.tag,skill_tree.lvl,user_stats.missions,user_stats.max_activity,user_stats.attack_w,user_stats.tournament_best,user_stats.tournament_won,TIMESTAMPDIFF(DAY,user.creation_time,user.last_login) as loyal, TIMESTAMPDIFF(DAY,user.creation_time,?) as beta FROM player_profile JOIN user ON player_profile.user_id=user.id JOIN items_pay ON items_pay.user_id=user.id JOIN skill_tree ON user.id=skill_tree.user_id JOIN user_stats ON user.id=user_stats.id LEFT JOIN crew on user.crew=crew.id WHERE user.id=?');
		$stmt->bindValue(1, '2017-09-03 00:00:00', PDO::PARAM_STR);
		$stmt->bindValue(2, $player_id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$badges=0;
			//Badges
			//Beta
			$betaBadge=0;
			if ($row['beta']>0) {
				if ($row['beta']>$row['loyal']) {
					$beta=$row['loyal'];
				}
				else {
					$beta=$row['beta'];
				}
				if ($beta>=100) { $betaBadge=3; $badges=$badges+1; }
				elseif ($beta>=60) { $betaBadge=2; $badges=$badges+1; }
				elseif ($beta>=30) { $betaBadge=1; $badges=$badges+1; }
			}
			//Loyal
			$loyalBadge=0;
			if ($row['loyal']>=365) { $loyalBadge=3; $badges=$badges+1; }
			elseif ($row['loyal']>=180) { $loyalBadge=2; $badges=$badges+1; }
			elseif ($row['loyal']>=90) { $loyalBadge=1; $badges=$badges+1; }
			//Addicted
			$addictedBadge=0;
			if ($row['max_activity']>=100) { $addictedBadge=3; $badges=$badges+1; }
			elseif ($row['max_activity']>=60) { $addictedBadge=2; $badges=$badges+1; }
			elseif ($row['max_activity']>=30) { $addictedBadge=1; $badges=$badges+1; }
			//Attacker
			$attackerBadge=0;
			if ($row['attack_w']>=50000) { $attackerBadge=3; $badges=$badges+1; }
			elseif ($row['attack_w']>=25000) { $attackerBadge=2; $badges=$badges+1; }
			elseif ($row['attack_w']>=10000) { $attackerBadge=1; $badges=$badges+1; }
			//Tournament
			$tournamentBadge=0;
			if ($row['tournament_won']>=100) { $tournamentBadge=3; $badges=$badges+1; }
			elseif ($row['tournament_won']>=50) { $tournamentBadge=2; $badges=$badges+1; }
			elseif ($row['tournament_won']>=25) { $tournamentBadge=1; $badges=$badges+1; }
			//Missions
			$missionBadge=0;
			if ($row['missions']>=1000) { $missionBadge=3; $badges=$badges+1; }
			elseif ($row['missions']>=500) { $missionBadge=2; $badges=$badges+1; }
			elseif ($row['missions']>=100) { $missionBadge=1; $badges=$badges+1; }
			//Supporter
			$supporterBadge=0;
			if ($gold>0) { $supporterBadge=3; $badges=$badges+1; }
			elseif ($silver>0) { $supporterBadge=2; $badges=$badges+1; }
			elseif ($bronze>0) { $supporterBadge=1; $badges=$badges+1; }
			
			$rows=intdiv($badges,5);
			if ($badges>0) { $rows=$rows+1; }
			
			$resp = "{\"username\": \"".$row['username']."\",\n"		
			."\"lvl\": \"".$row['lvl']."\",\n"
			."\"skin\": \"".$row['skin']."\",\n"
			."\"gc_role\": ".$row['gc_role'].",\n"
			."\"tournament_best\": ".$row['tournament_best'].",\n"
			."\"tournament_won\": ".$row['tournament_won'].",\n"
			."\"pic\": \"".$row['pic']."\",\n"
			."\"badges\": ".$badges.",\n"
			."\"rows\": ".$rows.",\n"
			."\"betaBadge\": ".$betaBadge.",\n"
			."\"loyalBadge\": ".$loyalBadge.",\n"
			."\"addictedBadge\": ".$addictedBadge.",\n"
			."\"attackerBadge\": ".$attackerBadge.",\n"
			."\"tournamentBadge\": ".$tournamentBadge.",\n"
			."\"missionBadge\": ".$missionBadge.",\n"
			."\"supporterBadge\": ".$supporterBadge.",\n"
			."\"tag\": \"".$row['tag']."\",\n";
		}	
		
		//Check Existing Contacts
		$stmt = $db->prepare("SELECT * FROM msg_contacts WHERE contact=? and uuid=(SELECT uuid FROM user WHERE id=?)"); 
		$stmt->bindValue(1, $player_uuid, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) { 
			$resp = $resp."\"contact\": \"N\",\n";
		}
		else {
			$resp = $resp."\"contact\": \"Y\",\n";
		}
		if ($id==$player_id) { $resp = $resp."\"contact\": \"Y\",\n"; }
		
		//RANK
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT score,missions_rep,rank FROM (SELECT id, username, score, missions_rep, @curRank := @curRank + 1 AS rank FROM user ORDER BY score DESC) as t WHERE id=?');
		$stmt->bindValue(1, $player_id, PDO::PARAM_INT);
		$stmt->execute();
		$db->commit();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = $resp."\"rank\": \"".$row['rank']."\",\n"
			."\"score\": \"".$row['score']."\",\n"			
			."\"rep\": \"".$row['missions_rep']."\",\n}";
		}		
		//echo $resp;
		echo base64_encode($resp);		
		
	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>