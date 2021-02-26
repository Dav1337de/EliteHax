<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT money,username,ip_change,skill_tree_reset FROM user JOIN items ON user.id=items.user_id WHERE items.user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$username=$row['username'];
			$money=$row['money'];
		}
		
		$stmt = $db->prepare("SELECT supporter.*,DATEDIFF(end_date,NOW()) as days_left FROM supporter WHERE user_id=? order by id desc limit 1"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$bronze=0;
		$silver=0;
		$gold=0;
			
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['type']=="supporter_bronze") { $bronze=$row['days_left']; }
			elseif ($row['type']=="supporter_silver") { $silver=$row['days_left']; }
			elseif ($row['type']=="supporter_gold") { $gold=$row['days_left']; }
		}
		$resp = "{\"username\": \"".$username."\",\n"
		."\"bronze\": ".$bronze.",\n"
		."\"silver\": ".$silver.",\n"
		."\"gold\": ".$gold.",\n"
		."\"money\": ".$money.",\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>