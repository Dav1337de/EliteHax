<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT money, username, user.crew, crew_role, slot, wallet FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$money = $row['money'];
			$username = $row['username'];
			$crew_role = $row['crew_role'];
			$slot = $row['slot'];
			$crew = $row['crew'];
			$wallet = $row['wallet'];
		}
		if ($crew_role > 2) { exit(); }
		$stmt = $db->prepare("SELECT count(id) as members FROM user WHERE crew=?"); 
		$stmt->bindValue(1, $crew, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$members = $row['members'];
		}
		
		$resp = "{\n\"status\": \"OK\",\n"
				."\"username\": \"".$username."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"members\": \"".$members."\",\n"
				."\"slot\": \"".$slot."\",\n"
				."\"wallet\": \"".$wallet."\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>