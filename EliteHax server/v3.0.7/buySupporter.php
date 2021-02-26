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
	$tdata = json_decode($_POST['tdata']);
	$item = $tdata->productId;
	if ($item=="it.elitehax.supporter_bronze") { $item="supporter_bronze"; }
	elseif ($item=="it.elitehax.supporter_silver") { $item="supporter_silver"; }
	elseif ($item=="it.elitehax.supporter_gold") { $item="supporter_gold"; }
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
		$stmt = $db->prepare("INSERT INTO supporter (user_id,type,purchase_date,end_date,purchase_id) VALUES (?,?,NOW(),DATE_ADD(NOW(), INTERVAL 30 DAY),?)"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $item, PDO::PARAM_INT);
		$stmt->bindValue(3, $tid, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO purchase (user_id,item,g_timestamp,timestamp) VALUES (?,?,?,NOW())"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $item, PDO::PARAM_INT);
		$stmt->bindValue(3, $tid, PDO::PARAM_INT);
		$stmt->execute();	
		
		$resp = "{\n\"enabled\": \"".$item."\",\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>