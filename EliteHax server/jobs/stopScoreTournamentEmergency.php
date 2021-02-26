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
	
		//Crew Rewards
		$stmt = $db->prepare("SELECT ztournament_score_finish_crew2.*,count(zuser2.id) as members, crew.tournament_best FROM ztournament_score_finish_crew2 JOIN zuser2 ON ztournament_score_finish_crew2.crew=zuser2.crew JOIN crew ON zuser2.crew=crew.id GROUP BY (zuser2.crew) ORDER BY rank");		
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
				$message="Congratulations ".$row['name']."! You have won a total of ".$creward." Cryptocoins (".$memberCC." per member) from yesterday tournament ended with Rank ".$row['rank'].". Sorry for the delay";
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
		

		echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "\n\nAn Error occured!\n$ex";
	}
?>