<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);

		$stmt = $db->prepare("SELECT global_chat.message,global_chat.user_id,user.username,DATE_SUB(global_chat.timestamp,INTERVAL 1 HOUR) as timestamp,user.gc_role,(SELECT DATEDIFF(end_date,NOW()) as days_left FROM supporter WHERE user_id=user.id and type='supporter_gold' order by id desc limit 1) as sup FROM global_chat LEFT JOIN user ON global_chat.user_id = user.id"); 
		$stmt->execute();

		$resp = "{\"global_chats\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$sup=0;
			if (is_null($row['sup'])) { $sup=0; }
			elseif ($row['sup']>0) { $sup=1; }
			$resp = $resp."{\"msg\": \"".$row['message']."\",\n"
			."\"timestamp\": \"".$row['timestamp']."\",\n"
			."\"supporter\": ".$sup.",\n";
			$resp = $resp."\"username\": \"".$row['username']."\",\n\"mod\": ".$row['gc_role'].",\n";
			if ($row['user_id'] == $id) { $resp = $resp."\"mine\": \"Y\"\n},"; }
			else { $resp = $resp."\"mine\": \"N\"\n},"; }
		}
		$resp = $resp."]}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>