<?php
	include 'db.php';
	include 'validate.php';
	//Validate Target Name
	if (!isset($_POST['t_name']))
		exit("");
	$t_name=trim($_POST['t_name']);
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\ ]/",$t_name) or (strlen($t_name)>18))
		exit("");
		
	//Validate Target IP
	if (!isset($_POST['t_ip']))
		exit("An Error occured!");
	if(filter_var($_POST['t_ip'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
	  $t_ip=$_POST['t_ip'];
	}
	else {
	  exit("");
	}
		
	//Validate Target Desc
	if (!isset($_POST['t_desc']))
		exit("");
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\ ]/",$_POST['t_desc']) or (strlen($_POST['t_desc'])>20))
		exit("");
	$t_desc = $_POST['t_desc'];
	
	try {
		$id = getIdFromToken($db);
		
		//Check number of Targets in Target List
		$stmt = $db->prepare('SELECT id FROM target_list WHERE user_id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();		
		if ($stmt->rowCount() >= 15) {
			echo base64_encode("{\"status\": \"TL\"}");
			exit();
		}
	
		//Check if IP already added
		$stmt = $db->prepare('SELECT id FROM target_list WHERE ip=? and user_id=?');
		$stmt->bindValue(1, sprintf('%u', ip2long($t_ip)), PDO::PARAM_STR);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();		
		if ($stmt->rowCount() != 0) {
			echo base64_encode("{\"status\": \"AA\"}");
			exit();
		}

		//Add Target to List
		$stmt = $db->prepare('INSERT INTO target_list (user_id, name, ip, description) VALUES (?,?,?,?)');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $t_name, PDO::PARAM_STR);
		$stmt->bindValue(3, sprintf('%u', ip2long($t_ip)), PDO::PARAM_STR);
		$stmt->bindValue(4, $t_desc, PDO::PARAM_STR);
		$stmt->execute();

		$resp = "{\n\"status\": \"OK\"\n}";			
		
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "";
	}
?>