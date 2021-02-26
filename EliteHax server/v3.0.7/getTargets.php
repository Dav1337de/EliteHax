<?php
	include 'db.php';
	include 'validate.php';
	try {
		
		$id = getIdFromToken($db);
		
		$checkNonce=checkNonce($db,$id);
		if ($checkNonce!=true) { exit("Nonce Issue"); }
		
		//Player Rank
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT rank, score, reputation, money, username FROM (SELECT id, username, score, reputation, money, @curRank := @curRank + 1 AS rank FROM user ORDER BY reputation+score DESC) as test WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	
		$db->commit();		
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$rank = $row['rank'];
			$resp = "{\"user\": \"".$row['username']."\","
			."\"money\": ".$row['money'].",";
		}			
		
		$num_filter = 100;
		$lower_limit = $rank-5;
		$lower_rank = $rank-$num_filter;
		if ($lower_rank<0) { $lower_rank=0; }
		if ($lower_limit<0) { $lower_limit=0; }
		$num_opponents = 8;
		
		if (isset($_POST['global'])) {
			if ($_POST['global'] == "true") {
				$num_filter = 1000000;
				$lower_rank=0;
			}
		}
		
		//Neighboor
		$min_fw = 999999;
		$max_fw = 0;
		$db->beginTransaction();
		$stmt = $db->prepare('SET @curRank := 0;');
		$stmt->execute();
		$stmt = $db->prepare('SELECT id,uuid,username,firewall,ip,TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(MAX(timestamp),INTERVAL 60 MINUTE)) as next_attack FROM (SELECT t.*,attack_log.timestamp FROM (SELECT id, uuid, username, firewall, ip from (SELECT user.id, uuid, username, score, reputation, ip, firewall, @curRank := @curRank + 1 AS rank FROM user JOIN upgrades on user.id=upgrades.id WHERE user.id != ? ORDER BY reputation+score DESC LIMIT ?,?) as neighboor ORDER BY rand() LIMIT ?) as t LEFT JOIN attack_log ON t.id = attack_log.defense_id and attack_log.attacker_id=?) as t2 GROUP BY id');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $lower_rank, PDO::PARAM_INT);
		$stmt->bindValue(3, $num_filter, PDO::PARAM_INT);
		$stmt->bindValue(4, $num_opponents, PDO::PARAM_INT);
		$stmt->bindValue(5, $id, PDO::PARAM_INT);
		$stmt->execute();
		$db->commit();	
		//$num_targets = 
		$resp = $resp."\"targets\":[\n";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['id'] != $id) {
				$interval = $row['next_attack'];
				$resp = $resp."{\"id\": \"".$row['uuid']."\","
				."\"ip\": \"".long2ip($row['ip'])."\",";
				if ($interval > 0) { $resp = $resp."\"attacked\": \"Y\",\n"; } 
				else { $resp = $resp."\"attacked\": \"N\",\n"; } 
				$resp = $resp."\"firewall\": \"".$row['firewall']."\""
				."},\n";
				if ($row['firewall'] < $min_fw) { $min_fw = $row['firewall']; }
				if ($row['firewall'] > $max_fw) { $max_fw = $row['firewall']; }
			}
		}
		$resp = $resp."],"
		."\"min_fw\": ".$min_fw.",\n"
		."\"max_fw\": ".$max_fw."}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>