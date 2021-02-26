<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_GET['pwd'])) { exit(); }
	if ($_GET['pwd'] != "HardCodedToChange") { exit(); }
	try {
		//$id = getIdFromToken($db);
		sleep(15);
		$stmt = $db->prepare("INSERT INTO game_statistics (timestamp,active_players,global_money,webs_attack,apps_attack,dbs_attack,money_attack,bot_count,rat_count) VALUES (NOW(),(SELECT count(id) FROM user WHERE DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= last_login),(SELECT sum(money) FROM user),(SELECT count(id) FROM `attack_log` WHERE DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp and type='webs'),(SELECT count(id) FROM `attack_log` WHERE DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp and type='apps'),(SELECT count(id) FROM `attack_log` WHERE DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp and type='dbs'),(SELECT count(id) FROM `attack_log` WHERE DATE_SUB(NOW(),INTERVAL 60 MINUTE) <= timestamp and type='money'),(SELECT count(id) FROM `botnet` ),(SELECT count(id) FROM `rat`))");		
		$stmt->execute();

		//echo "OK";
		exit();
	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>