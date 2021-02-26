<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['region']))
		exit("An Error occured!");
	$region = $_POST['region'];
	if (!is_numeric($region))
		exit("An Error occured!");
	if (($region<1) or ($region>18))
		exit("An Error occured!");
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT relocation FROM datacenter WHERE crew_id=(SELECT crew FROM user WHERE id=? and crew_role<=2)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$can_relocate=0;
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$can_relocate = $row['relocation'];
		}
		
		if ($can_relocate=="1") {
			$stmt = $db->prepare("UPDATE datacenter SET region=?,relocation=relocation-1,timestamp=NOW() WHERE crew_id=(SELECT crew FROM user WHERE id=?)"); 
			$stmt->bindValue(1, $region, PDO::PARAM_STR);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
		} else {
			exit(base64_encode("{\"status\": \"CL\",\n}"));
		}
		
		$resp = "{\"status\": \"OK\",\n}";
	
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>