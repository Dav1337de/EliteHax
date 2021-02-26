<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['pic']))
		exit("");
	$pic = $_POST['pic'];
	$whitelist = Array( '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11' );
	if( !in_array( $pic, $whitelist ) )
		exit("");
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("UPDATE player_profile SET pic=? WHERE user_id=?"); 
		$stmt->bindValue(1, $pic, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\"status\": \"OK\",\n}";
	
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>