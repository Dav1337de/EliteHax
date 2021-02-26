<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	try {
		$id = getIdFromToken($db);
		
		//Get Reward Status
		$stmt = $db->prepare('SELECT today_activity,current_activity,today_reward FROM user_stats WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$today_reward = $row['today_reward'];
			$current_activity = $row['current_activity'];
		}
		
		//Already given
		if ($today_reward == 1) { exit(); }

		//Get Reward
		$rewardt = getDailyReward($current_activity);
		$stmt = $db->prepare("UPDATE items SET {$rewardt}={$rewardt}+1 WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

		//Update Daily Reward
		$stmt = $db->prepare('UPDATE user_stats SET today_reward=1 WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_STR);
		$stmt->execute();		
					
		$resp = "{\n\"current_activity\": ".$current_activity.",\n"
		."\"reward\": \"".$rewardt."\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>