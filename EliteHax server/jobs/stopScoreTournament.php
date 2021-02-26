<?php
	include 'db.php';
	include 'timeandmoney.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	
	function getTournamentPReward($players,$rank) {
		$cc=0;
		$xp=0;
		if ($rank == 1) { $cc=500; $xp=100; }
		elseif ($rank == 2) { $cc=400; $xp=80; }
		elseif ($rank == 3) { $cc=350; $xp=70; }
		elseif ($rank == 4) { $cc=300; $xp=60; }
		elseif ($rank == 5) { $cc=250; $xp=50; }
		elseif (($rank >= 6) and ($rank<=10)) { $cc=200; $xp=40; }
		elseif (($rank >= 11) and ($rank<=25)) { $cc=100; $xp=20; }
		elseif (($rank >= 26) and ($rank<=50)) { $cc=75; $xp=15; }
		elseif (($rank >= 51) and ($rank<=100)) { $cc=50; $xp=10; }
		elseif (($rank >= 101) and ($rank<=200)) { $cc=30; $xp=6; }
		elseif (($rank >= 201) and ($rank<=500)) { $cc=20; $xp=4; }
		elseif (($rank >= 501) and ($rank<=1000)) { $cc=10; $xp=2; }
		if ($players<200) {
			$cc=round($cc*$players/200);
		}
		return array($cc,$xp);
	}
	
	function getTournamentCReward($crews,$rank) {
		$cc=0;
		if ($rank == 1) { $cc=1000; }
		elseif ($rank == 2) { $cc=800; }
		elseif ($rank == 3) { $cc=700; }
		elseif ($rank == 4) { $cc=600; }
		elseif ($rank == 5) { $cc=500; }
		elseif (($rank >= 6) and ($rank<=10)) { $cc=400; }
		elseif (($rank >= 11) and ($rank<=25)) { $cc=200; }
		elseif (($rank >= 26) and ($rank<=50)) { $cc=150; }
		elseif (($rank >= 51) and ($rank<=100)) { $cc=100; }
		elseif (($rank >= 101) and ($rank<=200)) { $cc=60; }
		elseif (($rank >= 201) and ($rank<=500)) { $cc=40; }
		elseif (($rank >= 501) and ($rank<=1000)) { $cc=20; }
		if ($crews<50) {
			$cc=round($cc*$crews/50);
		}
		return $cc;
	}	


	
	try {
		//$id = getIdFromToken($db);
		
		//Player Tables
		$stmt = $db->prepare("DROP TABLE IF EXISTS tournament_score_finish");		
		$stmt->execute();
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare("CREATE TABLE tournament_score_finish SELECT rank, id, username, score, tag FROM (SELECT id,username,money,score,tag, @curRank := @curRank + 1 AS rank FROM (SELECT user.id,user.username,(user.score-tournament_score_start.score) as score, user.money, crew.tag FROM user JOIN tournament_score_start ON user.id=tournament_score_start.id LEFT JOIN crew ON user.crew=crew.id WHERE (user.score-tournament_score_start.score)>0 ORDER BY (user.score-tournament_score_start.score) DESC,user.id ASC LIMIT 1000) as t) as t2");		
		$stmt->execute();
		$db->commit();
		
		//Crew Tables
		$stmt = $db->prepare("DROP TABLE IF EXISTS tournament_score_finish_crew");		
		$stmt->execute();
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare("CREATE TABLE tournament_score_finish_crew SELECT t3.* FROM (SELECT t2.*,@curRank := @curRank + 1 AS rank FROM (SELECT t.*,crew.name,crew.tag FROM (SELECT user.crew as crew,(SUM(user.score)-SUM(tournament_score_start.score)) as diff FROM user JOIN tournament_score_start ON tournament_score_start.id = user.id WHERE user.crew <> 0 GROUP BY crew HAVING ((SUM(user.score)-SUM(tournament_score_start.score))>0) and count(user.crew)>2 ORDER BY (SUM(user.score)-SUM(tournament_score_start.score)) DESC LIMIT 100000000) as t JOIN crew on t.crew=crew.id ORDER BY diff DESC LIMIT 1000) as t2) as t3");		
		$stmt->execute();
		$db->commit();
		
		//Player Rewards
		$stmt = $db->prepare("SELECT tournament_score_finish.*,skill_tree.lvl,skill_tree.xp,user_stats.tournament_best,user_stats.tournament_won FROM tournament_score_finish JOIN skill_tree ON tournament_score_finish.id=skill_tree.user_id JOIN user_stats ON skill_tree.user_id=user_stats.id");		
		$stmt->execute();
		$players=$stmt->rowCount();
		if ($players>0) {
			$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
			foreach ($arr as $row) {
				$preward = getTournamentPReward($players,$row['rank']);
				$id = $row['id'];
				$cc = $preward[0];
				$xp = $preward[1];
				$old_xp = $row['xp'];
				$tot_xp = $old_xp + $xp;
				$clvl = $row['lvl'];
				$lvl=$clvl+1;
				$new_lvl=0;
				$finished=false;
				$new_base=sommatoria($clvl);
				while (($lvl<=65) and ($finished==false)) {
					$sum=sommatoria($lvl);
					if ($sum > $tot_xp) { $finished=true; }
					else { $lvl++; $new_lvl++; $new_base=$sum; }
				}
				//Update CC and XP
				$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins+? WHERE id=?"); 
				$stmt->bindValue(1, $cc, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();		
				$stmt = $db->prepare("UPDATE skill_tree SET xp=xp+?,lvl=lvl+?,skill_points=skill_points+?,new_lvl_collected=? WHERE user_id=?"); 
				$stmt->bindValue(1, $xp, PDO::PARAM_INT);
				$stmt->bindValue(2, $new_lvl, PDO::PARAM_INT);
				$stmt->bindValue(3, $new_lvl, PDO::PARAM_INT);
				$stmt->bindValue(4, $new_lvl, PDO::PARAM_INT);
				$stmt->bindValue(5, $id, PDO::PARAM_INT);
				$stmt->execute();	
				//Update Tournament Stats
				if ($row['rank']==1) {
					$stmt = $db->prepare("UPDATE user_stats SET tournament_won=tournament_won+1 WHERE id=?"); 
					$stmt->bindValue(1, $id, PDO::PARAM_INT);
					$stmt->execute();	
				}
				if ($row['tournament_best']==0) {
					$stmt = $db->prepare("UPDATE user_stats SET tournament_best=? WHERE id=?"); 
					$stmt->bindValue(1, $row['rank'], PDO::PARAM_INT);
					$stmt->bindValue(2, $id, PDO::PARAM_INT);
					$stmt->execute();
				}
				elseif ($row['rank'] < $row['tournament_best']) {
					$stmt = $db->prepare("UPDATE user_stats SET tournament_best=? WHERE id=?"); 
					$stmt->bindValue(1, $row['rank'], PDO::PARAM_INT);
					$stmt->bindValue(2, $id, PDO::PARAM_INT);
					$stmt->execute();	
				}
				$message="Congratulations ".$row['username']."! You have won ".$cc." Cryptocoins and earned ".$xp." XP from the last tournament ended with Rank ".$row['rank'];
				//GitHub Note: 43fb468e8d0256ef63fc8824fd67a691 below is the uuid of the a system user used to send official ingame messages
				$stmt = $db->prepare("INSERT INTO `private_chat`(`uuid1`, `uuid2`, `message`, `timestamp`) SELECT '43fb468e8d0256ef63fc8824fd67a691',uuid,?,NOW() FROM user WHERE id=?"); 
				$stmt->bindValue(1, $message, PDO::PARAM_STR);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		

		//Crew Rewards
		$stmt = $db->prepare("SELECT tournament_score_finish_crew.*,count(user.id) as members, crew.tournament_best FROM tournament_score_finish_crew JOIN user ON tournament_score_finish_crew.crew=user.crew JOIN crew ON user.crew=crew.id GROUP BY (user.crew) ORDER BY rank");		
		$stmt->execute();
		$crews=$stmt->rowCount();
		if ($crews>0) {
			$arr = $stmt->fetchAll(PDO::FETCH_ASSOC);
			foreach ($arr as $row) {
				$creward = getTournamentCReward($crews,$row['rank']);
				$crew = $row['crew'];
				$members = $row['members'];
				$memberCC = round($creward/$members);
				//Update CC and XP
				$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins+? WHERE crew=?"); 
				$stmt->bindValue(1, $memberCC, PDO::PARAM_INT);
				$stmt->bindValue(2, $crew, PDO::PARAM_INT);
				$stmt->execute();		
				$message="Congratulations ".$row['name']."! You have won a total of ".$creward." Cryptocoins (".$memberCC." per member) from the last tournament ended with Rank ".$row['rank'];
				$stmt = $db->prepare("INSERT INTO crew_chat (crew_id,user_id,message,timestamp) VALUES (?,0,?,NOW())"); 
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->bindValue(2, $message, PDO::PARAM_STR);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM crew_chat WHERE crew_id=? and id NOT IN ( SELECT t.id FROM (SELECT id FROM crew_chat WHERE crew_id=? ORDER BY id DESC LIMIT 50 ) as t)"); 
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->bindValue(2, $crew, PDO::PARAM_INT);
				$stmt->execute();
				//Add Message to logs
				$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,field3,timestamp) VALUES ('tournament','score',?,?,?,?,NOW())");
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->bindValue(2, $creward, PDO::PARAM_STR);
				$stmt->bindValue(3, $memberCC, PDO::PARAM_STR);
				$stmt->bindValue(4, $row['rank'], PDO::PARAM_STR);
				$stmt->execute();
				//Update Tournament Stats
				if ($row['rank']==1) {
					$stmt = $db->prepare("UPDATE crew SET tournament_won=tournament_won+1 WHERE id=?"); 
					$stmt->bindValue(1, $crew, PDO::PARAM_INT);
					$stmt->execute();	
				}
				if ($row['tournament_best']==0) {
					$stmt = $db->prepare("UPDATE crew SET tournament_best=? WHERE id=?"); 
					$stmt->bindValue(1, $row['rank'], PDO::PARAM_INT);
					$stmt->bindValue(2, $crew, PDO::PARAM_INT);
					$stmt->execute();
				}
				elseif ($row['rank'] < $row['tournament_best']) {
					$stmt = $db->prepare("UPDATE crew SET tournament_best=? WHERE id=?"); 
					$stmt->bindValue(1, $row['rank'], PDO::PARAM_INT);
					$stmt->bindValue(2, $crew, PDO::PARAM_INT);
					$stmt->execute();	
				}
			}
		}

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>