<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT money,username,ip_change,skill_tree_reset FROM user JOIN items ON user.id=items.user_id WHERE items.user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = "{\"username\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"ip_change\": ".$row['ip_change'].",\n"
			."\"st_reset\": ".$row['skill_tree_reset'].",\n}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>