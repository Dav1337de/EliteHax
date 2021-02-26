<?php
	include 'db.php';
	include 'validate.php';
	$defense_type = $_POST['type'];
	$whitelist = Array( 'fwext', 'ips', 'siem', 'fwint1', 'fwint2', 'mf1', 'mf2' );
	if( !in_array( $defense_type, $whitelist ) )
		exit("An Error occured!");

	try {
		$id = getIdFromToken($db);
		
		//Cpoints & Mpoints
		$stmt = $db->prepare('SELECT datacenter.cpoints,user.crew_points,datacenter.id,user.crew FROM user JOIN datacenter ON user.crew=datacenter.crew_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$dc=$row['id'];
			$crew=$row['crew'];
			$cpoints=$row['cpoints'];
			$mpoints=$row['crew_points'];
		}
		if ($mpoints>=2) {
			exit(base64_encode("{\n\"status\": \"MAX\"\n}"));
		}			
		if ($cpoints>=50) {
			exit(base64_encode("{\n\"status\": \"CMAX\"\n}"));
		}
		
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
		
		$defended=0;
		if (($defense_type=='mf1') and ($mf1_as>0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET mf1=mf1-1,mf1_detected=mf1_detected-1 WHERE datacenter_id=? and mf1_detected=?");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $mf1_as, PDO::PARAM_INT);
			$stmt->execute();	
			$defended=1;
		}
		elseif (($defense_type=='mf2') and ($mf2_as>0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET mf2=mf2-1,mf2_detected=mf2_detected-1 WHERE datacenter_id=? and mf2_detected=?");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $mf2_as, PDO::PARAM_INT);
			$stmt->execute();
			$defended=1;			
		}
		elseif (($defense_type=='fwint1') and ($fwint1_as>0) and ($mf1_as==0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwint1=fwint1-1,fwint1_detected=fwint1_detected-1 WHERE datacenter_id=? and fwint1_detected=? and mf1=0");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $fwint1_as, PDO::PARAM_INT);
			$stmt->execute();	
			$defended=1;
		}
		elseif (($defense_type=='fwint2') and ($fwint2_as>0) and ($mf2_as==0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwint2=fwint2-1,fwint2_detected=fwint2_detected-1 WHERE datacenter_id=? and fwint2_detected=? and mf2=0");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $fwint2_as, PDO::PARAM_INT);
			$stmt->execute();	
			$defended=1;
		}
		elseif (($defense_type=='siem') and ($siem_as>0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET siem=siem-1,siem_detected=siem_detected-1 WHERE datacenter_id=? and siem_detected=?");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $siem_as, PDO::PARAM_INT);
			$stmt->execute();	
			$defended=1;
		}
		elseif (($defense_type=='ips') and ($ips_as>0) and ($fwint1_as==0) and ($fwint2_as==0) and ($siem_as==0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET ips=ips-1,ips_detected=ips_detected-1 WHERE datacenter_id=? and ips_detected=? and siem=0 and fwint1=0 and fwint2=0");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $ips_as, PDO::PARAM_INT);
			$stmt->execute();	
			$defended=1;
		}
		elseif (($defense_type=='fwext') and ($fwext_as>0) and ($ips_as==0)) {
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext=fwext-1,fwext_detected=fwext_detected-1 WHERE datacenter_id=? and fwext_detected=? and ips=0");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->bindValue(2, $fwext_as, PDO::PARAM_INT);
			$stmt->execute();	
			$defended=1;
		}
		else {
			exit(base64_encode("{\n\"status\": \"REFRESH\"\n}"));
		}

		$current_as=$defense_as-1;	
		
		//Datacenter Attack Log
		// $stmt = $db->prepare("INSERT INTO `datacenter_attack_logs` (attacking_crew,datacenter_id,attack_type,result,anon,attack_status,mf_hack,timestamp) VALUES ((SELECT crew FROM user WHERE id=?),?,?,?,?,?,?,NOW())");
		// $stmt->bindValue(1, $id, PDO::PARAM_INT);
		// $stmt->bindValue(2, $dc, PDO::PARAM_INT);
		// $stmt->bindValue(3, $attack_type, PDO::PARAM_STR);
		// $stmt->bindValue(4, $attack_result, PDO::PARAM_INT);
		// $stmt->bindValue(5, $anon_result, PDO::PARAM_INT);
		// $stmt->bindValue(6, $current_as, PDO::PARAM_INT);
		// $stmt->bindValue(7, $mf_hack, PDO::PARAM_STR);
		// $stmt->execute();	
		
		//Update cpoints & mpoints
		$stmt = $db->prepare("UPDATE user SET crew_points=crew_points+1 WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE datacenter SET cpoints=cpoints+1 WHERE crew_id=(SELECT crew FROM user WHERE id=?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Log
		$stmt = $db->prepare("INSERT INTO crew_wars_logs (crew,user_id,type,target,timestamp) VALUES (?,?,?,?,NOW())");
		$stmt->bindValue(1, $crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, "defense", PDO::PARAM_STR);
		$stmt->bindValue(4, $defense_type, PDO::PARAM_STR);
		$stmt->execute();
		
		//User, Money, cpoints, mpoints
		$stmt = $db->prepare('SELECT datacenter.cpoints,user.crew_points FROM user JOIN datacenter ON user.crew=datacenter.crew_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n"
			."\"cpoints\": ".$row['cpoints'].",\n"
			."\"mpoints\": ".$row['crew_points'].",\n"
			."\"current_as\": ".$current_as.",\n"
			."}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>