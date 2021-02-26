<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		if (!isset($_POST['message'])) { exit(); }
		//if (strlen($_POST['message'] < 1)) { exit(); }
		
		$message=urldecode($_POST['message']);
   		$escapers = array("\\", "/", "\"", "\n", "\r", "\t", "\x08", "\x0c");
    	$replacements = array("\\\\", "\\/", "\\\"", "\\n", "\\r", "\\t", "\\f", "\\b");
		$message = str_replace($escapers, $replacements, $message);
		$message=ltrim($message, '"');
		
		if ($message != "") {
		
		$stmt = $db->prepare("SELECT crew FROM user JOIN crew ON user.crew=crew.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$crew_id = $row['crew'];
		}

		$stmt = $db->prepare("INSERT INTO crew_chat (crew_id,user_id,message,timestamp) VALUES (?,?,?,NOW())"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, $message, PDO::PARAM_STR);
		$stmt->execute();
		
		$stmt = $db->prepare("DELETE FROM crew_chat WHERE crew_id=? and user_id<>0 and id NOT IN ( SELECT t.id FROM (SELECT id FROM crew_chat WHERE crew_id=? and user_id<>0 ORDER BY id DESC LIMIT 50 ) as t)"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
			
		}
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>