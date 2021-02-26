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
	$whitelist = Array( 'sp', 'mp', 'lp', 'ic', 'sm', 'mm', 'lm', 'so', 'mo', 'lo', 'ic', 'str' );
	if( !in_array( $type, $whitelist ) )
		exit("");
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT cryptocoins, money, username FROM user WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$cryptocoins = $row['cryptocoins'];
			$money = $row['money'];
			$username = $row['username'];
		}
		if ($type == "sp") { 
			$type = "small_packs";
			$cost=$qty*100; 
		}
		elseif ($type == "mp") { 
			$type = "medium_packs";
			$cost=$qty*200; 
		}
		elseif ($type == "lp") { 
			$type = "large_packs";
			$cost=$qty*400; 
		}
		elseif ($type == "sm") { 
			$type = "small_money";
			$cost=$qty*50; 
		}
		elseif ($type == "mm") { 
			$type = "medium_money";
			$cost=$qty*100; 
		}
		elseif ($type == "lm") { 
			$type = "large_money";
			$cost=$qty*200; 
		}
		elseif ($type == "so") { 
			$type = "small_oc_packs";
			$cost=$qty*75; 
		}
		elseif ($type == "mo") { 
			$type = "medium_oc_packs";
			$cost=$qty*150; 
		}
		elseif ($type == "lo") { 
			$type = "large_oc_packs";
			$cost=$qty*300;
		}
		elseif ($type == "ic") { 
			$type = "ip_change";
			$cost=$qty*2500;
		}
		elseif ($type == "str") { 
			$type = "skill_tree_reset";
			$cost=$qty*5000;
		}
		//Check Cryptocoins
		if ($cryptocoins >= $cost) {
			$stmt = $db->prepare("UPDATE items SET {$type}={$type}+? WHERE user_id=?"); 
			$stmt->bindValue(1, $qty, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins-? WHERE id=?"); 
			$stmt->bindValue(1, $cost, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
		}		
		else { exit(""); }
		
		$stmt = $db->prepare("SELECT uuid, cryptocoins, videos, money, username, small_packs, medium_packs, large_packs, small_money, medium_money, large_money, small_oc_packs, medium_oc_packs, large_oc_packs, ip_change, skill_tree_reset FROM user JOIN items ON user.id=items.user_id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$uuid = $row['uuid'];
			$cryptocoins = $row['cryptocoins'];
			$videos = $row['videos'];
			$money = $row['money'];
			$username = $row['username'];
			$sp = $row['small_packs'];
			$mp = $row['medium_packs'];
			$lp = $row['large_packs'];
			$sm = $row['small_money'];
			$mm = $row['medium_money'];
			$lm = $row['large_money'];
			$small_oc_packs = $row['small_oc_packs'];
			$medium_oc_packs = $row['medium_oc_packs'];
			$large_oc_packs = $row['large_oc_packs'];
			$ip_change = $row['ip_change'];
			$st_reset = $row['skill_tree_reset'];
		}
		$resp = "{\n\"status\": \"OK\",\n"
				."\"id\": \"".$uuid."\",\n"
				."\"username\": \"".$username."\",\n"
				."\"sp\": \"".$sp."\",\n"
				."\"mp\": \"".$mp."\",\n"
				."\"lp\": \"".$lp."\",\n"
				."\"sm\": \"".$sm."\",\n"
				."\"mm\": \"".$mm."\",\n"
				."\"lm\": \"".$lm."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"cc\": \"".$cryptocoins."\",\n"
				."\"small_oc_packs\": \"".$small_oc_packs."\",\n"
				."\"medium_oc_packs\": \"".$medium_oc_packs."\",\n"
				."\"large_oc_packs\": \"".$large_oc_packs."\",\n"
				."\"ip_change\": \"".$ip_change."\",\n"
				."\"st_reset\": \"".$st_reset."\",\n"
				."\"videos\": \"".$videos."\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>