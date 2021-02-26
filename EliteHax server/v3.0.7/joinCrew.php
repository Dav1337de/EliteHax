<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		//CHECK if user is not in a Crew
		$stmt = $db->prepare('SELECT username,crew FROM user WHERE user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['crew'] != 0) { 
				exit("An Error occured!");
			}
			$my_name = $row['username'];
		}
		//CHECK if Crew exists
		$stmt = $db->prepare('SELECT id FROM crew WHERE crew.id=?');
		$stmt->bindValue(1, $_POST['crew_id'], PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() == 0) {
			exit("An Error occured!");
		}
		//CHECK if request already sent
		$stmt = $db->prepare('SELECT crew_id FROM crew_requests WHERE crew_id=? and user_id=?');
		$stmt->bindValue(1, $_POST['crew_id'], PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount() != 0) {
			exit(base64_encode("{\n\"status\": \"AS\"\n}"));
		}
		$stmt = $db->prepare('INSERT INTO crew_requests (crew_id, user_id) VALUES (?,?)');
		$stmt->bindValue(1, $_POST['crew_id'], PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";		

		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,timestamp) VALUES ('action','request',?,?,NOW())");
		$stmt->bindValue(1, $_POST['crew_id'], PDO::PARAM_INT);
		$stmt->bindValue(2, $my_name, PDO::PARAM_STR);
		$stmt->execute();
	
		
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>