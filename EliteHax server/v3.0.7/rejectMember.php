<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("SELECT user.id,user.crew_role,user.crew,user.username FROM user WHERE user.id=? or user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['id'] == $id) {
				$crew_id = $row['crew'];
				$my_role = $row['crew_role'];
				$my_name = $row['username'];
			}
			elseif ($row['id'] == $_POST['member_id']) {
				$member_name = $row['username'];
			}
		}
		if ($my_role > 3) { exit("An Error occured!"); }
		
		//Delete Requests
		$stmt = $db->prepare("DELETE FROM crew_requests WHERE user_id=?"); 
		$stmt->bindValue(1, $_POST['member_id'], PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\"\n}";
		
		//Add Message to chat
		$message = $member_name." request has been reject by ".$my_name;
		$stmt = $db->prepare("INSERT INTO crew_chat (crew_id,user_id,message,timestamp) VALUES (?,0,?,NOW())"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $message, PDO::PARAM_STR);
		$stmt->execute();
		
		$stmt = $db->prepare("DELETE FROM crew_chat WHERE crew_id=? and id NOT IN ( SELECT t.id FROM (SELECT id FROM crew_chat WHERE crew_id=? ORDER BY id DESC LIMIT 50 ) as t)"); 
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $crew_id, PDO::PARAM_INT);
		$stmt->execute();
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>