<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare('SELECT datacenter.*,datacenter_upgrades.*,user.username,user.money,user.crew_points FROM user JOIN datacenter ON user.crew=datacenter.crew_id JOIN datacenter_upgrades ON datacenter.id=datacenter_upgrades.datacenter_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"my_region\": ".$row['region'].",\n"
			."\"relocation\": ".$row['relocation'].",\n"
			."\"cpoints\": ".$row['cpoints'].",\n"
			."\"mpoints\": ".$row['crew_points'].",\n"
			."\"mf_prod\": ".$row['mf_prod'].",\n"
			."\"mf1_testprod\": ".$row['mf1_testprod'].",\n"
			."\"mf2_testprod\": ".$row['mf2_testprod'].",\n"
			."\"fwext\": ".$row['fwext'].",\n"
			."\"ips\": ".$row['ips'].",\n"
			."\"siem\": ".$row['siem'].",\n"
			."\"fwint1\": ".$row['fwint1'].",\n"
			."\"fwint2\": ".$row['fwint2'].",\n"
			."\"mf1\": ".$row['mf1'].",\n"
			."\"mf2\": ".$row['mf2'].",\n"
			."\"scanner\": ".$row['scanner'].",\n"
			."\"relocate\": ".$row['relocate'].",\n"
			."\"anon\": ".$row['anon'].",\n"
			."\"exploit\": ".$row['exploit']."\n}";
		}
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>