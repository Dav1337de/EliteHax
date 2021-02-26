<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['type']))
		exit("");
	$type = $_POST['type'];
	$whitelist = Array( 'coolR1', 'missionR1', 'missionR2', 'missionR3', 'upgradeR1', 'upgradeR2', 'botR1', 'scannerR1', 'scannerR2', 'anonR1', 'anonR2', 'exploitR1', 'exploitR2', 'malwareR1', 'malwareR2', 'fwR1', 'fwR2', 'siemR1', 'siemR2', 'ipsR1', 'ipsR2', 'avR1', 'avR2', 'progR1', 'progR2' );
	if( !in_array( $type, $whitelist ) )
		exit("");
	
	function getResearchCost($type) {
		if (($type=='coolR1') or ($type=='missionR1') or ($type=='missionR2') or ($type=='upgradeR1') or ($type=='upgradeR2') or ($type=='botR1') or ($type=='scannerR1') or ($type=='anonR1') or ($type=='exploitR1') or ($type=='malwareR1') or ($type=='fwR1') or ($type=='siemR1') or ($type=='ipsR1') or ($type=='avR1') or ($type=='progR1')) {
			return 1000000;
		}
		else {
			return 10000000;
		}
	}		

	function getResearchTime($type) {
		if (($type=='coolR1') or ($type=='missionR1') or ($type=='missionR2') or ($type=='upgradeR1') or ($type=='upgradeR2') or ($type=='botR1') or ($type=='scannerR1') or ($type=='anonR1') or ($type=='exploitR1') or ($type=='malwareR1') or ($type=='fwR1') or ($type=='siemR1') or ($type=='ipsR1') or ($type=='avR1') or ($type=='progR1')) {
			return 3600;
		}
		elseif ($type=='missionR3') {
			return 10800;
		}
		else {
			return 7200;
		}
	}
	
	try {
		$id = getIdFromToken($db);
		$db->beginTransaction();
		$stmt = $db->prepare("SELECT research.*,COALESCE(TIMESTAMPDIFF(SECOND,NOW(),research.currentT),0) as seconds,user.username,user.money FROM user JOIN research ON user.id=research.user_id WHERE user.id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			//Check Running Researches
			if ($row['seconds'] > 0) { 
				$resp = "{\n\"status\": \"AR\"\n}";
				exit(base64_encode($resp));	
			}
			
			//Check Money
			$cost = getResearchCost($type);
			if ($cost>$row['money']) {
				$resp = "{\n\"status\": \"NO_MONEY\"\n}";
				exit(base64_encode($resp));
			}
			
			$time = getResearchTime($type);
		
			//Check Prrequisites
			if (($type == "upgradeR1") and ($row['missionR1']<10)) { exit(""); }
			if (($type == "upgradeR2") and ($row['missionR2']<10)) { exit(""); }
			if (($type == "upgradeR3") and (($row['missionR1']<50) or ($row['missionR2']<50))) { exit(""); }
			if (($type == "missionR1") and ($row['coolR1']<10)) { exit(""); }
			if (($type == "missionR2") and ($row['coolR1']<10)) { exit(""); }
			
			if (($type == "exploitR2") and ($row['exploitR1']<100)) { exit(""); }
			if (($type == "malwareR2") and ($row['malwareR1']<100)) { exit(""); }
			if (($type == "scannerR2") and ($row['scannerR1']<100)) { exit(""); }
			if (($type == "anonR2") and ($row['anonR1']<100)) { exit(""); }
			if (($type == "exploitR1") and ($row['scannerR1']<10)) { exit(""); }
			if (($type == "malwareR1") and ($row['anonR1']<10)) { exit(""); }
			if (($type == "scannerR1") and ($row['botR1']<10)) { exit(""); }
			if (($type == "anonR1") and ($row['botR1']<10)) { exit(""); }
			
			if (($type == "progR2") and ($row['progR1']<100)) { exit(""); }
			if (($type == "avR2") and ($row['avR1']<100)) { exit(""); }
			if (($type == "siemR2") and ($row['siemR1']<100)) { exit(""); }
			if (($type == "ipsR2") and ($row['ipsR1']<100)) { exit(""); }
			if (($type == "fwR2") and ($row['fwR1']<100)) { exit(""); }
			if (($type == "avR1") and ($row['siemR1']<10)) { exit(""); }
			if (($type == "progR1") and ($row['ipsR1']<10)) { exit(""); }
			if (($type == "siemR1") and ($row['fwR1']<10)) { exit(""); }
			if (($type == "ipsR1") and ($row['fwR1']<10)) { exit(""); }
			
			$cur_lvl = $row[$type];
			$new_lvl = $row[$type]+1;
			
			//CHECK UPPER LIMIT
			if ($cur_lvl == 100) {
				$resp = "{\n\"status\": \"MAX_LVL\"\n}";
				exit(base64_encode($resp));		
			}
			
			//UPDATE RESEARCH TREE AND MONEY
			$stmt = $db->prepare("UPDATE user SET money=money-? where id=?");
			$stmt->bindValue(1, $cost, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("UPDATE research SET {$type}={$type}+1,currentR=?,currentD=?,currentT=DATE_ADD(NOW(),INTERVAL ? SECOND) where user_id=?");
			$stmt->bindValue(1, $type, PDO::PARAM_STR);
			$stmt->bindValue(2, $time, PDO::PARAM_INT);
			$stmt->bindValue(3, $time, PDO::PARAM_INT);
			$stmt->bindValue(4, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			$stmt = $db->prepare("INSERT INTO research_audit (user_id,type,timestamp) VALUES (?,?,NOW())");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $type, PDO::PARAM_STR);
			$stmt->execute();
		}
		$db->commit();
		
		$resp = "{\n"
			."\"status\": \"OK\",\n"
			."\"new_lvl\": ".($new_lvl)."\n}";
		
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>
