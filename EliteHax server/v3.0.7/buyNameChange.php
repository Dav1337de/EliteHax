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

	$tid=$_POST['tid'];
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

		//Add Item
		$stmt = $db->prepare("UPDATE items_pay SET name_change=1 WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO purchase (user_id,item,g_timestamp,timestamp) VALUES (?,'name_change',?,NOW())"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $tid, PDO::PARAM_INT);
		$stmt->execute();	
		
		$resp = "{\n\"enabled\": 1,\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>