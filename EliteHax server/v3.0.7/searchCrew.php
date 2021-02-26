<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['types']))
		exit("An Error occured!");
	$type = $_POST['types'];
	$whitelist = Array( 'name', 'tag' );
	if( !in_array( $type, $whitelist ) )
		exit("An Error occured!");

	try {
		$id = getIdFromToken($db);
		
		if ($type == "name") { 
			$stmt = $db->prepare("SELECT crew.* FROM crew WHERE name LIKE CONCAT('%', ?, '%') LIMIT 10"); 
			$stmt->bindValue(1, $_POST['name'], PDO::PARAM_INT);
		}
		elseif ($type == "tag") { 
			$stmt = $db->prepare("SELECT crew.* FROM crew WHERE tag LIKE CONCAT('%', ?, '%') LIMIT 10"); 
			$stmt->bindValue(1, $_POST['tag'], PDO::PARAM_INT);
		}

		$stmt->execute();
		$resp = "{\"crews\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp
			."{\"name\": \"".$row['name']."\",\n"
			."\"id\": \"".$row['id']."\",\n"
			."\"tag\": \"".$row['tag']."\"\n},";
		}
		$resp = $resp."]}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>