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
			//CHECK 15msg/min for Ban
			$stmt = $db->prepare("SELECT count(global_chat.id) as msg FROM global_chat WHERE user_id=? and DATE_SUB(NOW(),INTERVAL 60 SECOND) <= timestamp"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);	
			$stmt->execute();			
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$msg_count_min = $row['msg'];
			}
			if ($msg_count_min >= 20) {
				$stmt = $db->prepare("UPDATE user SET gc_role=99 WHERE id=?"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);	
				$stmt->execute();	
			}
		
			//CHECK 4msg/15sec for Ignoring
			$stmt = $db->prepare("SELECT count(global_chat.id) as msg,user.gc_role FROM global_chat RIGHT JOIN user ON global_chat.user_id = user.id WHERE user_id=? and DATE_SUB(NOW(),INTERVAL 15 SECOND) <= timestamp"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);	
			$stmt->execute();			
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$msg_count = $row['msg'];
				$gc_role = $row['gc_role'];
			}
		
			if (($msg_count < 4) and ($gc_role != 99)) {			
				$stmt = $db->prepare("INSERT INTO global_chat (user_id,message,timestamp) VALUES (?,?,NOW())"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $message, PDO::PARAM_STR);
				$stmt->execute();
				
				$stmt = $db->prepare("DELETE FROM global_chat WHERE id NOT IN ( SELECT t.id FROM (SELECT id FROM global_chat ORDER BY id DESC LIMIT 50 ) as t)"); 
				$stmt->execute();
			}
		}
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>