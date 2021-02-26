<?php
	include 'db.php';
	include 'validate.php';
	//Validate Target Name
	if (!isset($_POST['t_name']))
		exit("");
	$t_name=trim($_POST['t_name']);
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\s]/",$t_name) or (strlen($t_name)>18))
		exit("");
		
	//Validate Target IP
	if (!isset($_POST['t_ip']))
		exit("");
	if(filter_var($_POST['t_ip'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
	  $t_ip=$_POST['t_ip'];
	}
	else {
	  exit("");
	}
		
	//Validate Target Desc
	if (!isset($_POST['t_desc']))
		exit("");
	$t_desc=trim($_POST['t_desc']);
	$t_desc=str_replace(array("\r","\n","\""), '', $t_desc);
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\s]/",$t_desc) or (strlen($t_desc)>20))
		exit("".$t_desc);
	
	try {
		$id = getIdFromToken($db);
	
		//Check if IP already added
		$stmt = $db->prepare('SELECT id FROM target_list WHERE ip=? and user_id=?');
		$stmt->bindValue(1, sprintf('%u', ip2long($t_ip)), PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		if ($stmt->rowCount() == 0) {
			exit("");
		}

		//Add Target to List
		$stmt = $db->prepare('UPDATE target_list SET name=?, description=? WHERE user_id=? and ip=?');
		$stmt->bindValue(1, $t_name, PDO::PARAM_STR);
		$stmt->bindValue(2, $t_desc, PDO::PARAM_STR);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->bindValue(4, sprintf('%u', ip2long($t_ip)), PDO::PARAM_STR);
		$stmt->execute();

		$resp = "{\n\"status\": \"OK\"\n}";			
		
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "";
	}
?>