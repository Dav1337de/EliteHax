<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT blue_skin,red_skin,yellow_skin,purple_skin,orange_skin,silver_skin,aqua_skin FROM items_pay WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$blue = $row['blue_skin'];
			$red = $row['red_skin'];
			$yellow = $row['yellow_skin'];
			$purple = $row['purple_skin'];
			$orange = $row['orange_skin'];
			$silver = $row['silver_skin'];
			$aqua = $row['aqua_skin'];
		}
		
		$resp = "{\n\"blue_skin\": ".$blue.",\n"
		."\"red_skin\": ".$red.",\n"
		."\"yellow_skin\": ".$yellow.",\n"
		."\"purple_skin\": ".$purple.",\n"
		."\"orange_skin\": ".$orange.",\n"
		."\"silver_skin\": ".$silver.",\n"
		."\"aqua_skin\": ".$aqua.",\n"
		."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>