<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['tid']))
		exit("");
	if (!isset($_POST['tdata']))
		exit("");
	if (!isset($_POST['tsignature']))
		exit("");
	//GitHub Note: You need to put your Google key to verify purchases
	if (verify_market_in_app($_POST['tdata'], $_POST['tsignature'], '<AddKeyHere>') == false) { exit("Signature not verified"); }
	if (!isset($_POST['skin']))
		exit("");
	$tid=$_POST['tid'];
	$skin = $_POST['skin'];
	$whitelist = Array( 'blue', 'red', 'yellow', 'purple', 'orange', 'silver', 'aqua' );
	if( !in_array( $skin, $whitelist ) )
		exit("");
	try {
		$id = getIdFromToken($db);
		//Already Processed
		$stmt = $db->prepare("SELECT id FROM purchase WHERE user_id=? and g_timestamp=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $tid, PDO::PARAM_INT);
		$stmt->execute();		
		if ($stmt->rowCount() != 0) {
			exit();
		}
		
		$skin_name=$skin."_skin";

		//Add Item
		$stmt = $db->prepare("UPDATE items_pay SET {$skin_name}=1 WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO purchase (user_id,item,g_timestamp,timestamp) VALUES (?,?,?,NOW())"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $skin_name, PDO::PARAM_INT);
		$stmt->bindValue(3, $tid, PDO::PARAM_INT);
		$stmt->execute();	
		
		//Get Skins
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