<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//Max Attack Number
		$stmt = $db->prepare('SELECT username,attack FROM user_stats JOIN user on user.id=user_stats.id ORDER BY attack DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"am_user".$i}=$row['username'];
			${"am_count".$i}=$row['attack'];
			$i++;
		}
		
		//Best Attack Won %
		$stmt = $db->prepare('SELECT user.id,username,(attack_w/attack*100) as A_P FROM user_stats JOIN user on user.id=user_stats.id WHERE attack>1000 ORDER BY (attack_w/attack) DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"ap_user".$i}=$row['username'];
			${"ap_count".$i}=$row['A_P'];
			$i++;
		}
		
		//Max Defense Number
		$stmt = $db->prepare('SELECT username,defense FROM user_stats JOIN user on user.id=user_stats.id ORDER BY defense DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"dm_user".$i}=$row['username'];
			${"dm_count".$i}=$row['defense'];
			$i++;
		}
		
		//Best Defense Won %
		$stmt = $db->prepare('SELECT user.id,username,(defense_w/defense*100) as D_P FROM user_stats JOIN user on user.id=user_stats.id WHERE defense>100 ORDER BY (defense_w/defense) DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"dp_user".$i}=$row['username'];
			${"dp_count".$i}=$row['D_P'];
			$i++;
		}
	
		//Best Attack
		$stmt = $db->prepare('SELECT username,best_attack FROM user_stats JOIN user on user.id=user_stats.id ORDER BY best_attack DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"ba_user".$i}=$row['username'];
			${"ba_count".$i}=$row['best_attack'];
			$i++;
		}
		
		//Highest Upgrades
		$stmt = $db->prepare('SELECT username,upgrades FROM user_stats JOIN user on user.id=user_stats.id ORDER BY upgrades DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"up_user".$i}=$row['username'];
			${"up_count".$i}=$row['upgrades'];
			$i++;
		}
		
		//Highest Money Spent
		$stmt = $db->prepare('SELECT username,money_spent FROM user_stats JOIN user on user.id=user_stats.id ORDER BY money_spent DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"ms_user".$i}=$row['username'];
			${"ms_count".$i}=$row['money_spent'];
			$i++;
		}
		
		//Highest XP
		$stmt = $db->prepare('SELECT username,xp FROM skill_tree JOIN user on user.id=skill_tree.user_id ORDER BY xp DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"xp_user".$i}=$row['username'];
			${"xp_count".$i}=$row['xp'];
			$i++;
		}
		
		//Best Tournament Players
		$stmt = $db->prepare('SELECT username,tournament_won FROM user_stats JOIN user on user.id=user_stats.id ORDER BY tournament_won DESC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"tw_user".$i}=$row['username'];
			${"tw_count".$i}=$row['tournament_won'];
			$i++;
		}
		
		//Best Tournament Crew
		$stmt = $db->prepare('SELECT name,tag,tournament_won FROM crew WHERE tournament_best<>0 ORDER BY tournament_won DESC,tournament_best ASC LIMIT 0,3');
		$stmt->execute();
		$i=1;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			${"ctw_crew".$i}=$row['name'];
			${"ctw_tag".$i}=$row['tag'];
			${"ctw_count".$i}=$row['tournament_won'];
			$i++;
		}
		
		$resp = "{\n\"status\": \"OK\",\n"
			."\"am_user1\": \"".$am_user1."\",\n"
			."\"am_count1\": \"".$am_count1."\",\n"
			."\"am_user2\": \"".$am_user2."\",\n"
			."\"am_count2\": \"".$am_count2."\",\n"
			."\"am_user3\": \"".$am_user3."\",\n"
			."\"am_count3\": \"".$am_count3."\",\n"
			."\"ap_user1\": \"".$ap_user1."\",\n"
			."\"ap_count1\": \"".round($ap_count1,2)."\",\n"
			."\"ap_user2\": \"".$ap_user2."\",\n"
			."\"ap_count2\": \"".round($ap_count2,2)."\",\n"
			."\"ap_user3\": \"".$ap_user3."\",\n"
			."\"ap_count3\": \"".round($ap_count3,2)."\",\n"
			."\"dm_user1\": \"".$dm_user1."\",\n"
			."\"dm_count1\": \"".$dm_count1."\",\n"
			."\"dm_user2\": \"".$dm_user2."\",\n"
			."\"dm_count2\": \"".$dm_count2."\",\n"
			."\"dm_user3\": \"".$dm_user3."\",\n"
			."\"dm_count3\": \"".$dm_count3."\",\n"
			."\"dp_user1\": \"".$dp_user1."\",\n"
			."\"dp_count1\": \"".round($dp_count1,2)."\",\n"
			."\"dp_user2\": \"".$dp_user2."\",\n"
			."\"dp_count2\": \"".round($dp_count2,2)."\",\n"
			."\"dp_user3\": \"".$dp_user3."\",\n"
			."\"dp_count3\": \"".round($dp_count3,2)."\",\n"
			."\"ba_user1\": \"".$ba_user1."\",\n"
			."\"ba_count1\": \"".$ba_count1."\",\n"
			."\"ba_user2\": \"".$ba_user2."\",\n"
			."\"ba_count2\": \"".$ba_count2."\",\n"
			."\"ba_user3\": \"".$ba_user3."\",\n"
			."\"ba_count3\": \"".$ba_count3."\",\n"
			."\"up_user1\": \"".$up_user1."\",\n"
			."\"up_count1\": \"".$up_count1."\",\n"
			."\"up_user2\": \"".$up_user2."\",\n"
			."\"up_count2\": \"".$up_count2."\",\n"
			."\"up_user3\": \"".$up_user3."\",\n"
			."\"up_count3\": \"".$up_count3."\",\n"
			."\"ms_user1\": \"".$ms_user1."\",\n"
			."\"ms_count1\": \"".$ms_count1."\",\n"
			."\"ms_user2\": \"".$ms_user2."\",\n"
			."\"ms_count2\": \"".$ms_count2."\",\n"
			."\"ms_user3\": \"".$ms_user3."\",\n"
			."\"ms_count3\": \"".$ms_count3."\",\n"
			."\"xp_user1\": \"".$xp_user1."\",\n"
			."\"xp_count1\": \"".$xp_count1."\",\n"
			."\"xp_user2\": \"".$xp_user2."\",\n"
			."\"xp_count2\": \"".$xp_count2."\",\n"
			."\"xp_user3\": \"".$xp_user3."\",\n"
			."\"xp_count3\": \"".$xp_count3."\",\n"
			."\"tw_user1\": \"".$tw_user1."\",\n"
			."\"tw_count1\": \"".$tw_count1."\",\n"
			."\"tw_user2\": \"".$tw_user2."\",\n"
			."\"tw_count2\": \"".$tw_count2."\",\n"
			."\"tw_user3\": \"".$tw_user3."\",\n"
			."\"tw_count3\": \"".$tw_count3."\",\n"
			."\"ctw_crew1\": \"".$ctw_crew1." (".$ctw_tag1.")\",\n"
			."\"ctw_count1\": \"".$ctw_count1."\",\n"
			."\"ctw_crew2\": \"".$ctw_crew2." (".$ctw_tag2.")\",\n"
			."\"ctw_count2\": \"".$ctw_count2."\",\n"
			."\"ctw_crew3\": \"".$ctw_crew3." (".$ctw_tag3.")\",\n"
			."\"ctw_count3\": \"".$ctw_count3."\",\n}";				
			
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>