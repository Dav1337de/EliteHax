<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	
	if (!isset($_POST['type']))
		exit("An Error occured!");
	$type = $_POST['type'];
	$whitelist = Array( 'internet', 'siem', 'firewall', 'ips', 'c2c', 'cpu', 'ram', 'hdd', 'gpu', 'fan', 'av', 'malware', 'exploit', 'siem', 'anon', 'webs', 'apps', 'dbs', 'scan', 'attack_w', 'missions', 'max_activity', 'loyal', 'videos' );
	if( !in_array( $type, $whitelist ) )
		exit("An Error occured!");
	
	function getReward($type) {
		if (($type=="internet") or ($type=="cpu") or ($type=="c2c") or ($type=="ram") or ($type=="hdd") or ($type=="fan") or ($type=="gpu") or ($type=="firewall") or ($type=="ips") or ($type=="av") or ($type=="malware") or ($type=="exploit") or ($type=="siem") or ($type=="anon") or ($type=="webs") or ($type=="apps") or ($type=="dbs") or ($type=="scan") or ($type=="attack_w") or ($type=="missions") or ($type=="max_activity")) {
			$result=20;
		}
		if (($type=="loyal") or ($type=="videos")) {
			$result=50;
		}
		return $result;
	}
	
	function limitReached($type,$achievement) {
		if (($type=="internet") or ($type=="cpu") or ($type=="c2c") or ($type=="ram") or ($type=="hdd") or ($type=="fan")) {
			$result=$achievement+2;
			if ($result>10) { $result=true; }
			else { $result=false; }
		}
		elseif (($type=="gpu") or ($type=="firewall") or ($type=="ips") or ($type=="av") or ($type=="malware") or ($type=="exploit") or ($type=="siem") or ($type=="anon") or ($type=="webs") or ($type=="apps") or ($type=="dbs") or ($type=="scan")) {
			$result=$achievement+2;
			if ($result>10) { $result=true; }
			else { $result=false; }
		}
		elseif (($type=="attack_w") or ($type=="missions") or ($type=="max_activity") or ($type=="loyal") or ($type=="videos")) {
			$result=$achievement+2;
			if ($result>10) { $result=true; }
			else { $result=false; }
		}
		return $result;
	}
	
	try {
		$id = getIdFromToken($db);
		
		//Get Achievement Current Level
		$stmt = $db->prepare("SELECT {$type},xp,lvl FROM achievement JOIN skill_tree ON achievement.user_id=skill_tree.user_id WHERE achievement.user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$type_a = $row[$type];
			$clvl = $row['lvl'];
			$old_xp = $row['xp'];
		}
		
		//Get Next Achievement
		$type_next = getNextLevel($type,$type_a);
		
		//Get Upgrades Level
		if (($type=="internet") or ($type=="cpu") or ($type=="c2c") or ($type=="ram") or ($type=="hdd") or ($type=="fan") or ($type=="gpu") or ($type=="firewall") or ($type=="ips") or ($type=="av") or ($type=="malware") or ($type=="exploit") or ($type=="siem") or ($type=="anon") or ($type=="webs") or ($type=="apps") or ($type=="dbs") or ($type=="scan")) {		
			$stmt = $db->prepare("SELECT {$type} FROM upgrades WHERE id=?"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$type_c = $row[$type];
			}	
		}
		elseif (($type=="attack_w") or ($type=="missions") or ($type=="max_activity") or ($type=="videos")) {
			$stmt = $db->prepare("SELECT {$type} FROM user_stats WHERE id=?"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$type_c = $row[$type];
			}	
		}
		elseif ($type=="loyal") {
			$stmt = $db->prepare("SELECT TIMESTAMPDIFF(DAY,creation_time,NOW()) AS loyal FROM user WHERE id=?"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$type_c = $row['loyal'];
			}	
		}
		
		//Previous not collected
		if (($type_c>=$type_next) and (limitReached($type,$type_a)==false)) { 
			$collect="Y";
			//Calculate new XP and Level
			$new_xp = getReward($type);
			$tot_xp=$old_xp+$new_xp;
			$lvl=$clvl+1;
			$new_lvl=0;
			$finished=false;
			$new_base=sommatoria($clvl);
			while (($lvl<=65) and ($finished==false)) {
				$sum=sommatoria($lvl);
				if ($sum > $tot_xp) { $finished=true; }
				else { $lvl++; $new_lvl++; $new_base=$sum; }
			}	
			//Update Achievement
			$stmt = $db->prepare("UPDATE achievement SET {$type}={$type}+1 WHERE user_id=?"); 
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			//Give Reward
			$stmt = $db->prepare("UPDATE skill_tree SET xp=?,lvl=lvl+?,skill_points=skill_points+?,new_lvl_collected=? WHERE user_id=?");
			$stmt->bindValue(1, $tot_xp, PDO::PARAM_INT);
			$stmt->bindValue(2, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(3, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(4, $new_lvl, PDO::PARAM_INT);
			$stmt->bindValue(5, $id, PDO::PARAM_INT);
			$stmt->execute();
		} 
		else { 
			$collect="N"; 
			$new_lvl=0;
		}

		$resp = $resp."{\"status\": \"OK\","
		."\"collect\": \"".$collect."\",\n"
		."\"new_lvl\": ".$new_lvl.",\n"
		."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n".$ex;
	}
?>