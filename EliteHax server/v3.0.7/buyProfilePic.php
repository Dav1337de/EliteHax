<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['tid']))
		exit("");
	if (!isset($_POST['pic']))
		exit("");
	if (!isset($_POST['tdata']))
		exit("");
	if (!isset($_POST['tsignature']))
		exit("");
	//GitHub Note: You need to put your Google key to verify purchases
	if (verify_market_in_app($_POST['tdata'], $_POST['tsignature'], '<AddKeyHere>') == false) { exit("Signature not verified"); }
	$tid=$_POST['tid'];
	$pic = $_POST['pic'];
	$whitelist = Array( '2', '3', '4', '5', '6', '7', '8', '9', '10', '12' );
	if( !in_array( $pic, $whitelist ) )
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
		
		if ($pic==2) {
			$pic_name="black_pic";
		}
		elseif ($pic==3) {
			$pic_name="gray_pic";
		}
		elseif ($pic==4) {
			$pic_name="ghost_pic";
		}
		elseif ($pic==5) {
			$pic_name="pirate_pic";
		}
		elseif ($pic==6) {
			$pic_name="ninja_pic";
		}
		elseif ($pic==7) {
			$pic_name="anon_pic";
		}
		elseif ($pic==8) {
			$pic_name="cyborg_pic";
		}
		elseif ($pic==9) {
			$pic_name="wolf_pic";
		}
		elseif ($pic==10) {
			$pic_name="tiger_pic";
		}
		elseif ($pic==12) {
			$pic_name="gas_mask_pic";
		}

		//Add Item
		$stmt = $db->prepare("UPDATE items_pay SET {$pic_name}=1 WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$stmt = $db->prepare("INSERT INTO purchase (user_id,item,g_timestamp,timestamp) VALUES (?,?,?,NOW())"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $pic_name, PDO::PARAM_INT);
		$stmt->bindValue(3, $tid, PDO::PARAM_INT);
		$stmt->execute();	
		
		//Get Pics
		$stmt = $db->prepare("SELECT black_pic,gray_pic,ghost_pic,pirate_pic,ninja_pic,anon_pic,cyborg_pic,wolf_pic,tiger_pic,gas_mask_pic FROM items_pay WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$bp = $row['black_pic'];
			$gp = $row['gray_pic'];
			$ghp = $row['ghost_pic'];
			$pp = $row['pirate_pic'];
			$np = $row['ninja_pic'];
			$ap = $row['anon_pic'];
			$cp = $row['cyborg_pic'];
			$wp = $row['wolf_pic'];
			$tp = $row['tiger_pic'];
			$gmp = $row['gas_mask_pic'];
		}
		
		$resp = "{\n\"black_pic\": ".$bp.",\n"
		."\"gray_pic\": ".$gp.",\n"
		."\"ghost_pic\": ".$ghp.",\n"
		."\"pirate_pic\": ".$pp.",\n"
		."\"ninja_pic\": ".$np.",\n"
		."\"anon_pic\": ".$ap.",\n"
		."\"cyborg_pic\": ".$cp.",\n"
		."\"wolf_pic\": ".$wp.",\n"
		."\"tiger_pic\": ".$tp.",\n"
		."\"gas_mask_pic\": ".$gmp.",\n"
		."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>