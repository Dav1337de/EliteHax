<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT user.id,user.username,user.money,user.score,user.missions_rep,user.crew_role,crew.name,TIMESTAMPDIFF(DAY,user.last_login,NOW()) as last_active FROM user JOIN crew ON user.crew=crew.id WHERE user.crew = (SELECT crew FROM user WHERE id=?) ORDER BY crew_role ASC, score DESC"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		$my_role=0;
		$resp = "{\"members\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$resp = $resp
			."{\"username\": \"".$row['username']."\",\n"
			."\"player_id\": \"".$row['id']."\",\n"
			."\"score\": \"".$row['score']."\",\n"
			."\"last_active\": \"".$row['last_active']."\",\n"
			."\"crew_role\": ".$row['crew_role'].",\n"
			."\"reputation\": \"".$row['missions_rep']."\"\n},";
			if ($row['id'] == $id) {
				$username = $row['username'];
				$money = $row['money'];
				$my_role = $row['crew_role'];
				$crew_name = $row['name'];
			}
		}
		$resp = $resp."],\n"
		."\"crew_name\": \"".$crew_name."\",\n"
		."\"username\": \"".$username."\",\n"
		."\"money\": ".$money.",\n"
		."\"my_role\": ".$my_role."\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>