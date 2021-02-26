<?php
	include 'db.php';
	include 'validate.php';
	if (!isset($_POST['dc']))
		exit("An Error occured!");
	if (!isset($_POST['type']))
		exit("An Error occured!");
	$dc = $_POST['dc'];
	if (!is_numeric($dc))
		exit("An Error occured!");
	$attack_type = $_POST['type'];
	$whitelist = Array( 'fwext', 'ips', 'siem', 'fwint1', 'fwint2', 'mf1', 'mf2' );
	if( !in_array( $attack_type, $whitelist ) )
		exit("An Error occured!");

	try {
		$id = getIdFromToken($db);
		
		//Check if datacenter has been scanned
		$stmt = $db->prepare("SELECT DISTINCT datacenter_id FROM `datacenter_scan` WHERE crew_id=(SELECT crew FROM user WHERE id=?) and TIMESTAMPDIFF(SECOND,timestamp,NOW())>0 and datacenter_id=? and region=(SELECT region FROM datacenter WHERE id=?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->bindValue(3, $dc, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) { exit(); }
		
		//Cpoints & Mpoints
		$stmt = $db->prepare('SELECT datacenter.cpoints,user.crew_points,user.crew FROM user JOIN datacenter ON user.crew=datacenter.crew_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$my_crew=$row['crew'];
			$cpoints=$row['cpoints'];
			$mpoints=$row['crew_points'];
		}
		if ($mpoints>=2) {
			exit(base64_encode("{\n\"status\": \"MAX\"\n}"));
		}			
		if ($cpoints>=50) {
			exit(base64_encode("{\n\"status\": \"CMAX\"\n}"));
		}
		
		//Get Attack Status
		$stmt = $db->prepare("SELECT * FROM `datacenter_attacks` where attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->execute();
		if ($stmt->rowCount()==0) {
			$first_attack=1;
		}
		else {
			$first_attack=0;
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$fwext_as=$row['fwext'];
				$ips_as=$row['ips'];
				$siem_as=$row['siem'];
				$fwint1_as=$row['fwint1'];
				$fwint2_as=$row['fwint2'];
				$mf1_as=$row['mf1'];
				$mf2_as=$row['mf2'];
			}			
		}
		
		//Check Attack Type vs Attack Status
		//fwext
		if (($first_attack==1) and ($attack_type != 'fwext')) { exit(); }
		elseif (($fwext_as<3) and ($attack_type != 'fwext')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		elseif (($fwext_as<3) and ($attack_type == 'fwext')) { $attack_type='fwext'; }
		elseif (($fwext_as==3) and ($attack_type == 'fwext')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		//ips
		elseif (($ips_as<3) and ($attack_type != 'ips')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		elseif (($ips_as<3) and ($attack_type == 'ips')) { $attack_type='ips'; }
		elseif (($ips_as==3) and ($attack_type == 'ips')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		//siem
		elseif (($siem_as<3) and ($attack_type == 'siem')) { $attack_type='siem'; }
		elseif (($siem_as==3) and ($attack_type == 'siem')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		//fwint1
		elseif (($fwint1_as<3) and ($attack_type == 'fwint1')) { $attack_type='fwint1'; }
		elseif (($fwint1_as==3) and ($attack_type == 'fwint1')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		//fwint2
		elseif (($fwint2_as<3) and ($attack_type == 'fwint2')) { $attack_type='fwint2'; }
		elseif (($fwint2_as==3) and ($attack_type == 'fwint2')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		//mf1
		elseif (($fwint1_as<3) and ($attack_type == 'mf1')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		elseif (($mf1_as<3) and ($attack_type == 'mf1')) { $attack_type='mf1'; }
		elseif (($mf1_as==3) and ($attack_type == 'mf1')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		//mf2
		elseif (($fwint2_as<3) and ($attack_type == 'mf2')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		elseif (($mf2_as<3) and ($attack_type == 'mf2')) { $attack_type='mf2'; }
		elseif (($mf2_as==3) and ($attack_type == 'mf2')) { exit(base64_encode("{\n\"status\": \"REFRESH\"\n}")); }
		else { exit(); }

		
		//My Stats
		$stmt = $db->prepare("SELECT anon,exploit FROM `datacenter_upgrades` WHERE datacenter_id=(SELECT id FROM datacenter WHERE crew_id=(SELECT crew FROM user WHERE id=?))");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$my_anon = $row['anon'];
			$my_exploit = $row['exploit'];
		}
		
		//Target Stats
		$stmt = $db->prepare("SELECT fwext,siem,ips,fwint1,fwint2,mf1,mf2,mf_prod FROM `datacenter_upgrades` WHERE datacenter_id=?");
		$stmt->bindValue(1, $dc, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$fwext = $row['fwext'];
			$siem = $row['siem'];
			$ips = $row['ips'];
			$fwint1 = $row['fwint1'];
			$fwint2 = $row['fwint2'];
			$mf1 = $row['mf1'];
			$mf2 = $row['mf2'];
			$mf_prod = $row['mf_prod'];
		}
		
		//fwExt
		if ($attack_type=='fwext') {
			$current_as=$fwext_as;
			$fwext_attack_c = floor(($my_exploit*125)/$fwext);
			if ($fwext_attack_c>95) { $fwext_attack_c=95; }
			$fwext_anon_c = floor(($my_anon*100)/(($fwext+$siem)*0.5));
			if ($fwext_anon_c>100) { $fwext_anon_c=100; }
			$final_chance = $fwext_attack_c;
			$final_anon = $fwext_anon_c;
		}
		
		//ips
		if ($attack_type=='ips') {
			$current_as=$ips_as;
			$ips_attack_c = floor(($my_exploit*100)/$ips);
			if ($ips_attack_c>95) { $ips_attack_c=95; }
			$ips_anon_c = floor(($my_anon*100)/(($ips+$siem)*0.75));
			if ($ips_anon_c>100) { $ips_anon_c=100; }
			$final_chance = $ips_attack_c;
			$final_anon = $ips_anon_c;
		}
		
		//siem
		if ($attack_type=='siem') {
			$current_as=$siem_as;
			$siem_attack_c = floor(($my_exploit*80)/$siem);
			if ($siem_attack_c>95) { $siem_attack_c=95; }
			$siem_anon_c = floor(($my_anon*100)/(($siem+$siem)*1));
			if ($siem_anon_c>100) { $siem_anon_c=100; }
			$final_chance = $siem_attack_c;
			$final_anon = $siem_anon_c;
		}
		
		//fwint1
		if ($attack_type=='fwint1') {
			$current_as=$fwint1_as;
			$fwint1_attack_c = floor(($my_exploit*80)/$fwint1);
			if ($fwint1_attack_c>95) { $fwint1_attack_c=95; }
			$fwint1_anon_c = floor(($my_anon*100)/(($fwint1+$siem)*1));
			if ($fwint1_anon_c>100) { $fwint1_anon_c=100; }
			$final_chance = $fwint1_attack_c;
			$final_anon = $fwint1_anon_c;
		}
		
		//fwint2
		if ($attack_type=='fwint2') {
			$current_as=$fwint2_as;
			$fwint2_attack_c = floor(($my_exploit*80)/$fwint2);
			if ($fwint2_attack_c>95) { $fwint2_attack_c=95; }
			$fwint2_anon_c = floor(($my_anon*100)/(($fwint2+$siem)*1));
			if ($fwint2_anon_c>100) { $fwint2_anon_c=100; }
			$final_chance = $fwint2_attack_c;
			$final_anon = $fwint2_anon_c;
		}
		
		//mf1
		if ($attack_type=='mf1') {
			$current_as=$mf1_as;
			$mf1_attack_c = floor(($my_exploit*60)/$mf1);
			if ($mf1_attack_c>95) { $mf1_attack_c=95; }
			$mf1_anon_c = floor(($my_anon*100)/(($mf1+$siem)*1.25));
			if ($mf1_anon_c>100) { $mf1_anon_c=100; }
			$final_chance = $mf1_attack_c;
			$final_anon = $mf1_anon_c;
		}
		
		//mf2
		if ($attack_type=='mf2') {
			$current_as=$mf2_as;
			$mf2_attack_c = floor(($my_exploit*60)/$mf2);
			if ($mf2_attack_c>95) { $mf2_attack_c=95; }
			$mf2_anon_c = floor(($my_anon*100)/(($mf2+$siem)*1.25));
			if ($mf2_anon_c>100) { $mf2_anon_c=100; }
			$final_chance = $mf2_attack_c;
			$final_anon = $mf2_anon_c;
		}
		
		//Attack!
		$attack = random_int(0,100);
		//Chance Cheat
		if (($final_chance > 90) and ($attack < (100-$final_chance))) { $attack = random_int(0,100); $final_chance=50; }
		if ($attack >= (100-$final_chance)) {
			$attack_result=1;
		}
		else { $attack_result=0; }
		
		//ANONYMOUS?
		$anon = rand(0,100);
		if ($anon >= (100-$final_anon)) { 
			$anon_result = 1; 
		} 
		else { $anon_result = 0; }
		//SIEM Disabled
		if ($siem_as==3) {
			$anon_result=1;
		}
		
		//Attack Status - Success
		if ($attack_result==1) {
			if ($first_attack==1) {
				//Insert First Attack
				$stmt = $db->prepare("INSERT INTO `datacenter_attacks` (attacking_crew,datacenter_id,fwext) VALUES ((SELECT crew FROM user WHERE id=?),?,1)");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
			else {
				//Update Attack
				$stmt = $db->prepare("UPDATE `datacenter_attacks` SET {$attack_type}={$attack_type}+1 WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		$current_as=$current_as+$attack_result;	
		if ($anon_result==0) {
			$detected_type=$attack_type."_detected";
			if ($attack_type=='fwext') {
				$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext_detected=? WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
				$stmt->bindValue(1, $current_as, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
			if ($attack_type=='ips') { 
				$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext_detected=3,ips_detected=? WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
				$stmt->bindValue(1, $current_as, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
			elseif (($attack_type=='siem') or ($attack_type=='fwint1') or ($attack_type=='fwint2')) {
				$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext_detected=3,ips_detected=3,{$detected_type}=? WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
				$stmt->bindValue(1, $current_as, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
			elseif ($attack_type=='mf1') {
				$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext_detected=3,ips_detected=3,fwint1_detected=3,mf1_detected=? WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
				$stmt->bindValue(1, $current_as, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
			elseif ($attack_type=='mf2') {
				$stmt = $db->prepare("UPDATE `datacenter_attacks` SET fwext_detected=3,ips_detected=3,fwint2_detected=3,mf2_detected=? WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
				$stmt->bindValue(1, $current_as, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->bindValue(3, $dc, PDO::PARAM_INT);
				$stmt->execute();
			}
		}
		
		//Check Mainframe Hack
		$mf_hack="n";
		if (($attack_type=="mf1") and ($current_as==3)) {
			if ($mf_prod==1) {
				$mf_hack="y";	
			}
			else {
				$mf_hack="t";
			}
		}
		elseif (($attack_type=="mf2") and ($current_as==3)) {
			if ($mf_prod==2) {
				$mf_hack="y";
			}
			else {
				$mf_hack="t";
			}
		}
		
		//Reward + Complete
		$money_reward=0;
		$cc_reward=0;
		if ($mf_hack=="y") {
			//My DC Power
			$stmt = $db->prepare("SELECT datacenter_id,(fwext+ips+siem+fwint1+fwint2+mf1+mf2+scanner+exploit+anon) as count FROM `datacenter_upgrades` WHERE datacenter_id=(SELECT id FROM datacenter WHERE crew_id=(SELECT crew FROM user WHERE id=?))");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$my_dc_power = $row['count'];
			}
			
			//Target DC Power
			$stmt = $db->prepare("SELECT datacenter_id,(fwext+ips+siem+fwint1+fwint2+mf1+mf2+scanner+exploit+anon) as count FROM `datacenter_upgrades` WHERE datacenter_id=?");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$dc_power = $row['count'];
			}
			
			//CC Reward 25/50/75/100/150
			$difficult_p=$dc_power/$my_dc_power*100;
			if ($difficult_p<=50) { $cc_reward=25; }
			elseif ($difficult_p<=75) { $cc_reward=50; }
			elseif ($difficult_p<=125) { $cc_reward=75; }
			elseif ($difficult_p<=175) { $cc_reward=100; }
			else { $cc_reward=150; }
			
			//Target Crew Wallet
			$stmt = $db->prepare("SELECT crew.wallet,crew.id FROM crew JOIN datacenter ON datacenter.crew_id=crew.id WHERE datacenter.id=?");
			$stmt->bindValue(1, $dc, PDO::PARAM_INT);
			$stmt->execute();
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
				$target_wallet = $row['wallet'];
				$target_crew = $row['id'];
			}
			//Money Reward 20%
			$money_reward=floor($target_wallet/100*20);
			
			//Update CC
			$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins+? WHERE crew=?");
			$stmt->bindValue(1, $cc_reward, PDO::PARAM_INT);
			$stmt->bindValue(2, $my_crew, PDO::PARAM_INT);
			$stmt->execute();
			
			//Update Wallet
			$stmt = $db->prepare("UPDATE crew SET wallet=wallet-? WHERE id=?");
			$stmt->bindValue(1, $money_reward, PDO::PARAM_INT);
			$stmt->bindValue(2, $target_crew, PDO::PARAM_INT);
			$stmt->execute();
			$stmt = $db->prepare("UPDATE crew SET wallet=wallet+? WHERE id=(SELECT crew FROM user WHERE id=?)");
			$stmt->bindValue(1, $money_reward, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();			
			
			//Complete Attack
			$stmt = $db->prepare("UPDATE `datacenter_attacks` SET completed=1,completed_timestamp=NOW() WHERE attacking_crew=(SELECT crew FROM user WHERE id=?) and datacenter_id=?");
			$stmt->bindValue(1, $id, PDO::PARAM_INT);
			$stmt->bindValue(2, $dc, PDO::PARAM_INT);
			$stmt->execute();
		}
		
		//Log
		$stmt = $db->prepare("INSERT INTO crew_wars_logs (crew,user_id,type,target,target2,timestamp) VALUES (?,?,?,?,?,NOW())");
		$stmt->bindValue(1, $my_crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->bindValue(3, "attack_d", PDO::PARAM_STR);
		$stmt->bindValue(4, $attack_type, PDO::PARAM_STR);
		$stmt->bindValue(5, $dc, PDO::PARAM_STR);		
		$stmt->execute();
		
		//Datacenter Attack Log
		$stmt = $db->prepare("INSERT INTO `datacenter_attack_logs` (attacking_crew,datacenter_id,attack_type,result,anon,attack_status,mf_hack,cc_reward,money_reward,region,timestamp) VALUES ((SELECT crew FROM user WHERE id=?),?,?,?,?,?,?,?,?,(SELECT region FROM datacenter where id=?),NOW())");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $dc, PDO::PARAM_INT);
		$stmt->bindValue(3, $attack_type, PDO::PARAM_STR);
		$stmt->bindValue(4, $attack_result, PDO::PARAM_INT);
		$stmt->bindValue(5, $anon_result, PDO::PARAM_INT);
		$stmt->bindValue(6, $current_as, PDO::PARAM_INT);
		$stmt->bindValue(7, $mf_hack, PDO::PARAM_STR);
		$stmt->bindValue(8, $cc_reward, PDO::PARAM_INT);
		$stmt->bindValue(9, $money_reward, PDO::PARAM_INT);
		$stmt->bindValue(10, $dc, PDO::PARAM_INT);
		$stmt->execute();	
		
		//Update cpoints & mpoints
		$stmt = $db->prepare("UPDATE user SET crew_points=crew_points+1 WHERE id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		$stmt = $db->prepare("UPDATE datacenter SET cpoints=cpoints+1 WHERE crew_id=(SELECT crew FROM user WHERE id=?)");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		//User, Money, cpoints, mpoints
		$stmt = $db->prepare('SELECT datacenter.cpoints,user.crew_points FROM user JOIN datacenter ON user.crew=datacenter.crew_id where user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$resp = "{\n"
			."\"cpoints\": ".$row['cpoints'].",\n"
			."\"mpoints\": ".$row['crew_points'].",\n"
			."\"attack_result\": ".$attack_result.",\n"
			."\"anon_result\": ".$anon_result.",\n"
			."\"current_as\": ".$current_as.",\n"
			."\"mf_hack\": \"".$mf_hack."\",\n"
			."\"cc_reward\": ".$cc_reward.",\n"
			."\"money_reward\": ".$money_reward.",\n"
			."}";
		}
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>