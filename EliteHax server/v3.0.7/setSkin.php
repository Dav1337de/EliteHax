<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['skin']))
		exit("");
	$skin = $_POST['skin'];
	$whitelist = Array( 'green', 'blue', 'red', 'yellow', 'purple', 'orange', 'silver', 'aqua' );
	if( !in_array( $skin, $whitelist ) )
		exit("");
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("UPDATE player_profile SET skin=? WHERE user_id=?"); 
		$stmt->bindValue(1, $skin, PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\"status\": \"OK\",\n}";
	
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>