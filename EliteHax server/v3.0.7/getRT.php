<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT research.*,COALESCE(TIMESTAMPDIFF(SECOND,NOW(),research.currentT),0) as seconds,user.username,user.money FROM user JOIN research ON user.id=research.user_id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$money = $row['money'];
			$username = $row['username'];
			$coolR1 = $row['coolR1'];
			$missionR1 = $row['missionR1'];
			$missionR2 = $row['missionR2'];
			$missionR3 = $row['missionR3'];
			$upgradeR1 = $row['upgradeR1'];
			$upgradeR2 = $row['upgradeR2'];
			$botR1 = $row['botR1'];
			$scannerR1 = $row['scannerR1'];
			$scannerR2 = $row['scannerR2'];
			$anonR1 = $row['anonR1'];
			$anonR2 = $row['anonR2'];
			$exploitR1 = $row['exploitR1'];
			$exploitR2 = $row['exploitR2'];
			$malwareR1 = $row['malwareR1'];
			$malwareR2 = $row['malwareR2'];
			$fwR1 = $row['fwR1'];
			$fwR2 = $row['fwR2'];
			$siemR1 = $row['siemR1'];
			$siemR2 = $row['siemR2'];
			$ipsR1 = $row['ipsR1'];
			$ipsR2 = $row['ipsR2'];
			$avR1 = $row['avR1'];
			$avR2 = $row['avR2'];
			$progR1 = $row['progR1'];
			$progR2 = $row['progR2'];
			$current_r = $row['currentR'];
			if ($current_r != nil) {
				$current_l = $row[$row['currentR']];
			} else { $current_l = 0; }
			$duration = $row['currentD'];
			$secondsLeft = $row['seconds'];
		}	
		
		$resp = "{\n\"status\": \"OK\",\n"
				."\"username\": \"".$username."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"secondsLeft\": \"".$secondsLeft."\",\n"
				."\"duration\": \"".$duration."\",\n"
				."\"current_r\": \"".$current_r."\",\n"
				."\"current_l\": \"".$current_l."\",\n"
				."\"coolR1\": \"".$coolR1."\",\n"
				."\"missionR1\": \"".$missionR1."\",\n"
				."\"missionR2\": \"".$missionR2."\",\n"
				."\"missionR3\": \"".$missionR3."\",\n"
				."\"upgradeR1\": \"".$upgradeR1."\",\n"
				."\"upgradeR2\": \"".$upgradeR2."\",\n"
				."\"botR1\": \"".$botR1."\",\n"
				."\"scannerR1\": \"".$scannerR1."\",\n"
				."\"scannerR2\": \"".$scannerR2."\",\n"
				."\"anonR1\": \"".$anonR1."\",\n"
				."\"anonR2\": \"".$anonR2."\",\n"
				."\"exploitR1\": \"".$exploitR1."\",\n"
				."\"exploitR2\": \"".$exploitR2."\",\n"
				."\"malwareR1\": \"".$malwareR1."\",\n"
				."\"malwareR2\": \"".$malwareR2."\",\n"
				."\"fwR1\": \"".$fwR1."\",\n"
				."\"fwR2\": \"".$fwR2."\",\n"
				."\"siemR1\": \"".$siemR1."\",\n"
				."\"siemR2\": \"".$siemR2."\",\n"
				."\"ipsR1\": \"".$ipsR1."\",\n"
				."\"ipsR2\": \"".$ipsR2."\",\n"
				."\"avR1\": \"".$avR1."\",\n"
				."\"avR2\": \"".$avR2."\",\n"
				."\"progR1\": \"".$progR1."\",\n"
				."\"progR2\": \"".$progR2."\",\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>