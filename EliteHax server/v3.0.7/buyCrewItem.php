<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['type']) or !isset($_POST['qty']))
		exit("");
	$qty = $_POST['qty'];
	if (!is_numeric($qty))
		exit("");
	if ($qty < 1) 
		exit("");
	$type = $_POST['type'];
	$whitelist = Array( 'new_slot', 'sp', 'mp', 'lp', 'ic', 'sm', 'mm', 'lm', 'so', 'mo', 'lo' );
	if( !in_array( $type, $whitelist ) )
		exit("");
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
		if ($type == "new_slot") {
			$type = "new_slot";
			$cost=pow(1.5,($slot-10))*50000000;
		}
		if ($type == "sp") { 
			$type = "small_packs";
			$type_log = "Small Pack";
			$cost=$qty*10000000*$members; 
		}
		elseif ($type == "mp") { 
			$type = "medium_packs";
			$type_log = "Medium Pack";
			$cost=$qty*20000000*$members; 
		}
		elseif ($type == "lp") { 
			$type = "large_packs";
			$type_log = "Large Pack";
			$cost=$qty*40000000*$members; 
		}
		elseif ($type == "sm") { 
			$type = "small_money";
			$type_log = "Small Money Pack";
			$cost=$qty*5000000*$members; 
		}
		elseif ($type == "mm") { 
			$type = "medium_money";
			$type_log = "Medium Money Pack";
			$cost=$qty*10000000*$members; 
		}
		elseif ($type == "lm") { 
			$type = "large_money";
			$type_log = "Large Money Pack";
			$cost=$qty*20000000*$members; 
		}
		elseif ($type == "so") { 
			$type = "small_oc_packs";
			$type_log = "Small Overclock Pack";
			$cost=$qty*7500000*$members; 
		}
		elseif ($type == "mo") { 
			$type = "medium_oc_packs";
			$type_log = "Medium Overclock Pack";
			$cost=$qty*15000000*$members; 
		}
		elseif ($type == "lo") { 
			$type = "large_oc_packs";
			$type_log = "Large Overclock Pack";
			$cost=$qty*30000000*$members; 
		}
		if ($qty>1) {
			$type_log=$type_log."s";
		}
		//Check Cryptocoins
		if ($wallet >= $cost) {
			if ($type=="new_slot") {
				$stmt = $db->prepare("UPDATE crew SET slot=slot+1 WHERE id=?"); 
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->execute();	
				
				$message = $username." bought a new slot (".($slot+1).") for the crew";
				$stmt = $db->prepare("INSERT INTO crew_chat (crew_id,user_id,message,timestamp) VALUES (?,0,?,NOW())"); 
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->bindValue(2, $message, PDO::PARAM_STR);
				$stmt->execute();
				
				$stmt = $db->prepare("DELETE FROM crew_chat WHERE crew_id=? and user_id=0 and id NOT IN ( SELECT t.id FROM (SELECT id FROM crew_chat WHERE crew_id=? and user_id=0 ORDER BY id DESC LIMIT 50 ) as t)"); 
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->bindValue(2, $crew, PDO::PARAM_INT);
				$stmt->execute();				
			}
			else {
				$stmt = $db->prepare("UPDATE items SET {$type}={$type}+? WHERE user_id IN (SELECT id FROM user WHERE crew=?);"); 
				$stmt->bindValue(1, $qty, PDO::PARAM_INT);
				$stmt->bindValue(2, $crew, PDO::PARAM_INT);
				$stmt->execute();
				
				//Add Message to logs
				$stmt = $db->prepare("INSERT INTO crew_logs (type,subtype,crew_id,field1,field2,field3,timestamp) VALUES ('action','buy',?,?,?,?,NOW())");
				$stmt->bindValue(1, $crew, PDO::PARAM_INT);
				$stmt->bindValue(2, $type_log, PDO::PARAM_STR);
				$stmt->bindValue(3, $username, PDO::PARAM_STR);
				$stmt->bindValue(4, $qty, PDO::PARAM_STR);
				$stmt->execute();
			}
			$stmt = $db->prepare("UPDATE crew SET wallet=wallet-? WHERE id=?"); 
			$stmt->bindValue(1, $cost, PDO::PARAM_INT);
			$stmt->bindValue(2, $crew, PDO::PARAM_INT);
			$stmt->execute();
		}		
		else { exit(""); }
		
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
		$stmt = $db->prepare("SELECT count(id) as members FROM user WHERE crew=?"); 
		$stmt->bindValue(1, $crew, PDO::PARAM_INT);
		$stmt->execute();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$members = $row['members'];
		}
		$resp = "{\n\"status\": \"OK\",\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>