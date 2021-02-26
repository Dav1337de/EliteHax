<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$db->beginTransaction();
		$stmt = $db->prepare("SELECT cryptocoins,videos FROM items JOIN user ON items.user_id=user.id WHERE user_id = ?");
		$stmt->bindValue(1, $id, PDO::PARAM_STR);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$cc = $row['cryptocoins'];
			$videos = $row['videos'];
		} 
		$stmt = $db->prepare("SELECT user_id,timestamp FROM rewards WHERE user_id=? and DATE_SUB(NOW(),INTERVAL MINUTE(NOW()) MINUTE) <= timestamp");
		$stmt->bindValue(1, $id, PDO::PARAM_STR);
		$stmt->execute();			
		if ($stmt->rowCount() < 2) {
			// grant the rewards
			$stmt = $db->prepare("INSERT INTO rewards (user_id,reward,timestamp) VALUES (?,10,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_STR);
			$stmt->execute();
			$reward=10;
			$stmt = $db->prepare("UPDATE items SET videos = videos+1 WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_STR);
			$stmt->execute();
			$stmt = $db->prepare("UPDATE user_stats SET videos = videos+1 WHERE id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_STR);
			$stmt->execute();
			$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins+? WHERE id=?");
			$stmt->bindValue(1, $reward, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_STR);
			$stmt->execute();
			$videos=$videos+1;
			$new_cc = $cc+$reward;
		} else {
			$new_cc=$cc;
		}
		$db->commit();
		$resp = "{\n\"status\": \"OK\",\n\"cc\": \"".$new_cc."\",\n\"videos\": \"".$videos."\"\n}";
		//echo $resp;
		echo base64_encode($resp);			
		
	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>