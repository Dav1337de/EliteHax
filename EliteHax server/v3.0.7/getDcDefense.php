<?php
	include 'db.php';
	include 'validate.php';

	try {
		$id = getIdFromToken($db);

		//Initialize
		$fwext_as=0;
		$ips_as=0;
		$siem_as=0;
		$fwint1_as=0;
		$fwint2_as=0;
		$mf1_as=0;
		$mf2_as=0;
		
		//Attack Status	
		$stmt = $db->prepare("SELECT * FROM `datacenter_attacks` where datacenter_id=(SELECT id FROM datacenter WHERE completed=0 and crew_id=(SELECT crew FROM user WHERE id=?))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();	
			
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if (($row['mf1_detected']>$mf1_as) and ($row['mf1']==$row['mf1_detected'])) { $mf1_as=$row['mf1_detected']; }
			if (($row['fwint1_detected']>$fwint1_as) and ($row['fwint1']==$row['fwint1_detected'])  and ($row['mf1']==$row['mf1_detected'])) { $fwint1_as=$row['fwint1_detected']; }
			if (($row['mf2_detected']>$mf2_as) and ($row['mf2']==$row['mf2_detected'])) { $mf2_as=$row['mf2_detected']; }
			if (($row['fwint2_detected']>$fwint2_as) and ($row['fwint2']==$row['fwint2_detected']) and ($row['mf2']==$row['mf2_detected'])) { $fwint2_as=$row['fwint2_detected']; }
			if (($row['siem_detected']>$siem_as) and ($row['siem']==$row['siem_detected'])) { $siem_as=$row['siem_detected']; }		
			$ips_visible=false;
			if (($row['ips_detected']>$ips_as) and ($row['ips']==$row['ips_detected'])) {
				$left_tree=false;
				$right_tree=false;			
				if (($row['fwint1']==$row['fwint1_detected']) and ($row['mf1']==$row['mf1_detected']) and ($row['fwint1']>0)) { $left_tree=true; }
				if (($row['fwint2']==$row['fwint2_detected']) and ($row['mf2']==$row['mf2_detected']) and ($row['fwint2']>0)) { $right_tree=true; }
				if (($row['fwint1']==0) and ($row['fwint2']==0)) {
					$left_tree=true;
					$right_tree=true;
				}				
				if (($left_tree==true) or ($right_tree==true)) { 
					$ips_as=$row['ips_detected']; 
					$ips_visible=true;
				}
				if (($row['siem_detected']==$row['siem']) and ($row['siem']>0)) { 
					$ips_as=$row['ips_detected']; 
					$ips_visible=true;
				}
			}		
			if (($row['fwext_detected']>$fwext_as) and ($row['fwext']==$row['fwext_detected'])) {
				if (($ips_visible==true) or ($row['ips']==0)) { $fwext_as=$row['fwext_detected']; }
			}			
		}					

		//User, Money, cpoints, mpoints
		$stmt = $db->prepare('SELECT datacenter.cpoints,user.username,user.money,user.crew_points,datacenter_upgrades.mf_prod FROM user JOIN datacenter ON user.crew=datacenter.crew_id JOIN datacenter_upgrades ON datacenter.id=datacenter_upgrades.datacenter_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n"
			."\"user\": \"".$row['username']."\",\n"
			."\"money\": ".$row['money'].",\n"
			."\"cpoints\": ".$row['cpoints'].",\n"
			."\"mpoints\": ".$row['crew_points'].",\n"
			."\"fwext_as\": ".$fwext_as.",\n"
			."\"ips_as\": ".$ips_as.",\n"
			."\"siem_as\": ".$siem_as.",\n"
			."\"fwint1_as\": ".$fwint1_as.",\n"
			."\"fwint2_as\": ".$fwint2_as.",\n"
			."\"mf1_as\": ".$mf1_as.",\n"
			."\"mf2_as\": ".$mf2_as.",\n"
			."\"mf_prod\": ".$row['mf_prod'].",\n"
			."}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>