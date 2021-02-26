<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['new_name']))
		exit("");
	$new_name=$_POST['new_name'];
	if (!validateUser($new_name)) { exit(); }
	try {
		$id = getIdFromToken($db);

		//Check active user and e-mails
		$stmt = $db->prepare('SELECT username FROM user WHERE username=?');
		$stmt->bindValue(1, $new_name, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (strcasecmp($new_name, $row['username']) == 0) { exit(base64_encode("{\"status\": \"UE\"}")); }
			}
		}
		//Check pending user and e-mails
		$stmt = $db->prepare('SELECT username FROM register_pending WHERE username=?');
		$stmt->bindValue(1, $new_name, PDO::PARAM_STR);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				if (strcasecmp($new_name, $row['username']) == 0) { exit(base64_encode("{\"status\": \"UE\"}")); }
			}
		}
		
		//Check Name Change Item
		$stmt = $db->prepare('SELECT name_change FROM items_pay WHERE user_id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['name_change'] == 0) { exit(); }
		}	

		//Change Name
		$stmt = $db->prepare("UPDATE user SET username=? WHERE id=?"); 
		$stmt->bindValue(1, $new_name, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE tournament_hack SET username=? WHERE id=?"); 
		$stmt->bindValue(1, $new_name, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE tournament_score_start SET username=? WHERE id=?"); 
		$stmt->bindValue(1, $new_name, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE tournament_score_finish SET username=? WHERE id=?"); 
		$stmt->bindValue(1, $new_name, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Consume Item
		$stmt = $db->prepare("UPDATE items_pay SET name_change=0 WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\"status\": \"OK\",\n"
		."\"new_name\": \"".$new_name."\",\n"
		."}";
	
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>