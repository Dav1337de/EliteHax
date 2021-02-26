<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['username']))
		exit("");
	$username=$_POST['username'];
	try {
		$id = getIdFromToken($db);
		
		//Check My GC Role
		$stmt = $db->prepare("SELECT gc_role FROM user WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_STR);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$my_gc_role=$row['gc_role'];
		}	
		if (($my_gc_role!=1) and ($my_gc_role!=2)) {
			exit();	
		}
		else {	
			//Check Existing Username
			$stmt = $db->prepare("SELECT id,gc_role FROM user WHERE username=?"); 
			$stmt->bindValue(1, $username, PDO::PARAM_STR);
			$stmt->execute();
			if ($stmt->rowCount() == 0) { 
				exit();		
			}		
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$ban_id=$row['id'];
				$ban_gc_role=$row['gc_role'];
			}
			if (($ban_gc_role!=1) and ($ban_gc_role!=2)) {
				//BAN!
				$stmt = $db->prepare("UPDATE user SET gc_role=99 WHERE id=?"); 
				$stmt->bindValue(1, $ban_id, PDO::PARAM_INT);
				$stmt->execute();
				//Add Log
				$stmt = $db->prepare("INSERT INTO ban_log (mod_id,ban_id,ban_username,timestamp) VALUES (?,?,?,NOW())"); 
				$stmt->bindValue(1, $id, PDO::PARAM_STR);
				$stmt->bindValue(2, $ban_id, PDO::PARAM_INT);
				$stmt->bindValue(3, $username, PDO::PARAM_STR);
				$stmt->execute();

				$resp = "{\"status\": \"OK\"\n}";
				//echo $resp;
				echo base64_encode($resp);
			}
		}

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>