<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		//Validate Crew Wallet Percentage
		if (!isset($_POST['new_walletp']))
			exit("An Error occured!");
		if (($_POST['new_walletp'] < 2) or ($_POST['new_walletp'] > 10))
			exit("An Error occured!");
			
		$stmt = $db->prepare("SELECT user.id,user.username,user.crew_role,crew.name,user.crew FROM user JOIN crew ON user.crew=crew.id WHERE user.crew = (SELECT crew FROM user WHERE id=?) and user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
			$my_role = $row['crew_role'];
			$my_name = $row['username'];
		}
		//Check Role
		if ($my_role > 2) { exit("An Error occured!"); }
		
		$stmt = $db->prepare("UPDATE crew SET wallet_p=? WHERE id=?"); 
		$stmt->bindValue(1, $_POST['new_walletp'], PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//Add Message to logs
		$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,timestamp) VALUES ('action','wallet_p',?,?,?,NOW())");
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['new_walletp'], PDO::PARAM_STR);
		$stmt->bindValue(3, $my_name, PDO::PARAM_STR);
		$stmt->execute();
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>