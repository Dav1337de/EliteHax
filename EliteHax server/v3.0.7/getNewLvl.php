<?php
	include 'db.php';
	include 'validate.php';
		
	try {
		$id = getIdFromToken($db);
		//Get Achievement Current Level
		$stmt = $db->prepare("SELECT new_lvl_collected,lvl FROM skill_tree WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$new_lvl_collected = $row['new_lvl_collected'];
			$lvl = $row['lvl'];
		}	
		
		if ($new_lvl_collected==0) {	
			$resp = "{\n\"status\": \"AC\"}";
		}
		else {
			$stmt = $db->prepare("UPDATE skill_tree SET new_lvl_collected=0 WHERE user_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			$resp = "{\n\"status\": \"OK\"\n,\"lvl\": ".$lvl."\n}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>