<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare('SELECT * FROM user JOIN user_stats on user.id = user_stats.id WHERE user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"score\": \"".$row['score']."\",\n"
			."\"reputation\": \"".$row['reputation']."\",\n"
			."\"attack\": \"".$row['attack']."\",\n"
			."\"attack_w\": \"".$row['attack_w']."\",\n"
			."\"attack_l\": \"".$row['attack_l']."\",\n"
			."\"best_attack\": ".$row['best_attack'].",\n"
			."\"defense\": \"".$row['defense']."\",\n"
			."\"defense_w\": \"".$row['defense_w']."\",\n"
			."\"defense_l\": \"".$row['defense_l']."\",\n"
			."\"worst_defense\": ".$row['worst_defense'].",\n"
			."\"money_w\": \"".$row['money_w']."\",\n"
			."\"money_l\": \"".$row['money_l']."\",\n"
			."\"rep_w\": \"".$row['rep_w']."\",\n"
			."\"rep_l\": \"".$row['rep_l']."\",\n"
			."\"upgrades\": \"".$row['upgrades']."\",\n"
			."\"money_spent\": \"".$row['money_spent']."\",\n"
			."\"money\": ".$row['money'].",\n";			
		}		
		$resp = $resp."}";
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>