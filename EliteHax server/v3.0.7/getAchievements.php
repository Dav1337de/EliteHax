<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	
	if (!isset($_POST['sort']))
		exit("An Error occured!");
	$sort=$_POST['sort'];
	$whitelist = Array( 'levelA', 'levelD', 'completeA', 'completeD' );
	if( !in_array( $sort, $whitelist ) )
		exit("An Error occured!");
	
	try {
		$id = getIdFromToken($db);
		
		//Get Achievement Current Level
		$stmt = $db->prepare("SELECT * FROM achievement WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$internet_a = $row['internet'];
			$cpu_a = $row['cpu'];
			$c2c_a = $row['c2c'];
			$ram_a = $row['ram'];
			$hdd_a = $row['hdd'];
			$fan_a = $row['fan'];
			$gpu_a = $row['gpu'];
			$firewall_a = $row['firewall'];
			$ips_a = $row['ips'];
			$av_a = $row['av'];
			$malware_a = $row['malware'];
			$exploit_a = $row['exploit'];
			$siem_a = $row['siem'];
			$anon_a = $row['anon'];
			$webs_a = $row['webs'];
			$apps_a = $row['apps'];
			$dbs_a = $row['dbs'];
			$scan_a = $row['scan'];
			$attack_w_a = $row['attack_w'];
			$missions_a = $row['missions'];
			$logins_a = $row['max_activity'];
			$loyal_a = $row['loyal'];
		}
		
		//Get Upgrades Level
		$stmt = $db->prepare("SELECT * FROM upgrades WHERE id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$internet = $row['internet'];
			$cpu = $row['cpu'];
			$c2c = $row['c2c'];
			$ram = $row['ram'];
			$hdd = $row['hdd'];
			$fan = $row['fan'];
			$gpu = $row['gpu'];
			$firewall = $row['firewall'];
			$ips = $row['ips'];
			$av = $row['av'];
			$malware = $row['malware'];
			$exploit = $row['exploit'];
			$siem = $row['siem'];
			$anon = $row['anon'];
			$webs = $row['webs'];
			$apps = $row['apps'];
			$dbs = $row['dbs'];
			$scan = $row['scan'];
		}		
		//Get Stats
		$stmt = $db->prepare("SELECT attack_w,max_activity,missions,videos,TIMESTAMPDIFF(DAY,user.creation_time,NOW()) AS loyal FROM user_stats JOIN user ON user_stats.id=user.id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$attack_w = $row['attack_w'];
			$missions = $row['missions'];
			$logins = $row['max_activity'];
			$loyal = $row['loyal'];
		}		
		
		//Get Next Achievement
		$internet_next = getNextLevel('internet',$internet_a);
		$cpu_next = getNextLevel('cpu',$cpu_a);
		$c2c_next = getNextLevel('c2c',$c2c_a);
		$ram_next = getNextLevel('ram',$ram_a);
		$hdd_next = getNextLevel('hdd',$hdd_a);
		$fan_next = getNextLevel('fan',$fan_a);
		$gpu_next = getNextLevel('gpu',$gpu_a);
		$firewall_next = getNextLevel('firewall',$firewall_a);
		$ips_next = getNextLevel('ips',$ips_a);
		$av_next = getNextLevel('av',$av_a);
		$malware_next = getNextLevel('malware',$malware_a);
		$exploit_next = getNextLevel('exploit',$exploit_a);
		$siem_next = getNextLevel('siem',$siem_a);
		$anon_next = getNextLevel('anon',$anon_a);
		$webs_next = getNextLevel('webs',$webs_a);
		$apps_next = getNextLevel('apps',$apps_a);
		$dbs_next = getNextLevel('dbs',$dbs_a);
		$scan_next = getNextLevel('scan',$scan_a);
		$attack_w_next = getNextLevel('attack_w',$attack_w_a);
		$missions_next = getNextLevel('missions',$missions_a);
		$logins_next = getNextLevel('max_activity',$logins_a);
		$loyal_next = getNextLevel('loyal',$loyal_a);
		
		//Completion %
		$internet_p = $internet/$internet_next;
		$cpu_p = $cpu/$cpu_next;
		$c2c_p = $c2c/$c2c_next;
		$ram_p = $ram/$ram_next;
		$hdd_p = $hdd/$hdd_next;
		$fan_p = $fan/$fan_next;
		$gpu_p = $gpu/$gpu_next;
		$firewall_p = $firewall/$firewall_next;
		$ips_p = $ips/$ips_next;
		$av_p = $av/$av_next;
		$malware_p = $malware/$malware_next;
		$exploit_p = $exploit/$exploit_next;
		$siem_p = $siem/$siem_next;
		$anon_p = $anon/$anon_next;
		$webs_p = $webs/$webs_next;
		$apps_p = $apps/$apps_next;
		$dbs_p = $dbs/$dbs_next;
		$scan_p = $scan/$scan_next;
		$attack_w_p = $attack_w/$attack_w_next;
		$missions_p = $missions/$missions_next;
		$logins_p = $logins/$logins_next;
		$loyal_p = $loyal/$loyal_next;
	
		//Sort Achievement
		if ($sort=='levelA') {
			$achievements = array("internet"=>$internet_a,"cpu"=>$cpu_a,"c2c"=>$c2c_a,"ram"=>$ram_a,"hdd"=>$hdd_a,"fan"=>$fan_a,"gpu"=>$gpu_a,"firewall"=>$firewall_a,"ips"=>$ips_a,"av"=>$av_a,"malware"=>$malware_a,"exploit"=>$exploit_a,"attack_w"=>$attack_w_a,"missions"=>$missions_a,"logins"=>$logins_a,"siem"=>$siem_a,"anon"=>$anon_a,"webs"=>$webs_a,"apps"=>$apps_a,"dbs"=>$dbs_a,"scan"=>$scan_a,"loyal"=>$loyal_a);
			asort($achievements);
		}
		elseif ($sort=='levelD') {
			$achievements = array("internet"=>$internet_a,"cpu"=>$cpu_a,"c2c"=>$c2c_a,"ram"=>$ram_a,"hdd"=>$hdd_a,"fan"=>$fan_a,"gpu"=>$gpu_a,"firewall"=>$firewall_a,"ips"=>$ips_a,"av"=>$av_a,"malware"=>$malware_a,"exploit"=>$exploit_a,"attack_w"=>$attack_w_a,"missions"=>$missions_a,"logins"=>$logins_a,"siem"=>$siem_a,"anon"=>$anon_a,"webs"=>$webs_a,"apps"=>$apps_a,"dbs"=>$dbs_a,"scan"=>$scan_a,"loyal"=>$loyal_a);
			arsort($achievements);
		}
		elseif ($sort=='completeD') {
			$achievements = array("internet"=>$internet_p,"cpu"=>$cpu_p,"c2c"=>$c2c_p,"ram"=>$ram_p,"hdd"=>$hdd_p,"fan"=>$fan_p,"gpu"=>$gpu_p,"firewall"=>$firewall_p,"ips"=>$ips_p,"av"=>$av_p,"malware"=>$malware_p,"exploit"=>$exploit_p,"attack_w"=>$attack_w_p,"missions"=>$missions_p,"logins"=>$logins_p,"siem"=>$siem_p,"anon"=>$anon_p,"webs"=>$webs_p,"apps"=>$apps_p,"dbs"=>$dbs_p,"scan"=>$scan_p,"loyal"=>$loyal_p);
			arsort($achievements);
		}
		elseif ($sort=='completeA') {
			$achievements = array("internet"=>$internet_p,"cpu"=>$cpu_p,"c2c"=>$c2c_p,"ram"=>$ram_p,"hdd"=>$hdd_p,"fan"=>$fan_p,"gpu"=>$gpu_p,"firewall"=>$firewall_p,"ips"=>$ips_p,"av"=>$av_p,"malware"=>$malware_p,"exploit"=>$exploit_p,"attack_w"=>$attack_w_p,"missions"=>$missions_p,"logins"=>$logins_p,"siem"=>$siem_p,"anon"=>$anon_p,"webs"=>$webs_p,"apps"=>$apps_p,"dbs"=>$dbs_p,"scan"=>$scan_p,"loyal"=>$loyal_p);
			asort($achievements);
		}
		
		//Previous not collected
		if ($internet>$internet_next) { $internet=$internet_next; }
		if ($cpu>$cpu_next) { $cpu=$cpu_next; }
		if ($c2c>$c2c_next) { $c2c=$c2c_next; }
		if ($ram>$ram_next) { $ram=$ram_next; }
		if ($hdd>$hdd_next) { $hdd=$hdd_next; }
		if ($fan>$fan_next) { $fan=$fan_next; }
		if ($gpu>$gpu_next) { $gpu=$gpu_next; }
		if ($firewall>$firewall_next) { $firewall=$firewall_next; }
		if ($ips>$ips_next) { $ips=$ips_next; }
		if ($av>$av_next) { $av=$av_next; }
		if ($malware>$malware_next) { $malware=$malware_next; }
		if ($exploit>$exploit_next) { $exploit=$exploit_next; }
		if ($siem>$siem_next) { $siem=$siem_next; }
		if ($anon>$anon_next) { $anon=$anon_next; }
		if ($webs>$webs_next) { $webs=$webs_next; }
		if ($apps>$apps_next) { $apps=$apps_next; }
		if ($dbs>$dbs_next) { $dbs=$dbs_next; }
		if ($scan>$scan_next) { $scan=$scan_next; }
		if ($attack_w>$attack_w_next) { $attack_w=$attack_w_next; }
		if ($missions>$missions_next) { $missions=$missions_next; }
		if ($logins>$logins_next) { $logins=$logins_next; }
		if ($loyal>$loyal_next) { $loyal=$loyal_next; }

		//Username and Money
		$stmt = $db->prepare('SELECT username,money FROM user WHERE id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$username=$row['username'];
			$money=$row['money'];	
		}			

		$resp = $resp."{\"status\": \"OK\","
		."\"user\": \"".$username."\",\n"		
		."\"money\": ".$money.",\n"	
		."\"internet_c\": ".$internet.",\n"
		."\"internet_a\": ".$internet_next.",\n"
		."\"internet_p\": ".array_search("internet",array_keys($achievements)).",\n"
		."\"cpu_c\": ".$cpu.",\n"
		."\"cpu_a\": ".$cpu_next.",\n"
		."\"cpu_p\": ".array_search("cpu",array_keys($achievements)).",\n"
		."\"c2c_c\": ".$c2c.",\n"
		."\"c2c_a\": ".$c2c_next.",\n"
		."\"c2c_p\": ".array_search("c2c",array_keys($achievements)).",\n"
		."\"ram_c\": ".$ram.",\n"
		."\"ram_a\": ".$ram_next.",\n"
		."\"ram_p\": ".array_search("ram",array_keys($achievements)).",\n"
		."\"hdd_c\": ".$hdd.",\n"
		."\"hdd_a\": ".$hdd_next.",\n"
		."\"hdd_p\": ".array_search("hdd",array_keys($achievements)).",\n"
		."\"fan_c\": ".$fan.",\n"
		."\"fan_a\": ".$fan_next.",\n"
		."\"fan_p\": ".array_search("fan",array_keys($achievements)).",\n"
		."\"gpu_c\": ".$gpu.",\n"
		."\"gpu_a\": ".$gpu_next.",\n"
		."\"gpu_p\": ".array_search("gpu",array_keys($achievements)).",\n"
		."\"firewall_c\": ".$firewall.",\n"
		."\"firewall_a\": ".$firewall_next.",\n"
		."\"firewall_p\": ".array_search("firewall",array_keys($achievements)).",\n"
		."\"ips_c\": ".$ips.",\n"
		."\"ips_a\": ".$ips_next.",\n"
		."\"ips_p\": ".array_search("ips",array_keys($achievements)).",\n"
		."\"av_c\": ".$av.",\n"
		."\"av_a\": ".$av_next.",\n"
		."\"av_p\": ".array_search("av",array_keys($achievements)).",\n"
		."\"malware_c\": ".$malware.",\n"
		."\"malware_a\": ".$malware_next.",\n"
		."\"malware_p\": ".array_search("malware",array_keys($achievements)).",\n"
		."\"exploit_c\": ".$exploit.",\n"
		."\"exploit_a\": ".$exploit_next.",\n"
		."\"exploit_p\": ".array_search("exploit",array_keys($achievements)).",\n"		
		."\"siem_c\": ".$siem.",\n"
		."\"siem_a\": ".$siem_next.",\n"
		."\"siem_p\": ".array_search("siem",array_keys($achievements)).",\n"
		."\"anon_c\": ".$anon.",\n"
		."\"anon_a\": ".$anon_next.",\n"
		."\"anon_p\": ".array_search("anon",array_keys($achievements)).",\n"
		."\"webs_c\": ".$webs.",\n"
		."\"webs_a\": ".$webs_next.",\n"
		."\"webs_p\": ".array_search("webs",array_keys($achievements)).",\n"
		."\"apps_c\": ".$apps.",\n"
		."\"apps_a\": ".$apps_next.",\n"
		."\"apps_p\": ".array_search("apps",array_keys($achievements)).",\n"
		."\"dbs_c\": ".$dbs.",\n"
		."\"dbs_a\": ".$dbs_next.",\n"
		."\"dbs_p\": ".array_search("dbs",array_keys($achievements)).",\n"
		."\"scan_c\": ".$scan.",\n"
		."\"scan_a\": ".$scan_next.",\n"
		."\"scan_p\": ".array_search("scan",array_keys($achievements)).",\n"		
		."\"attack_w_c\": ".$attack_w.",\n"
		."\"attack_w_a\": ".$attack_w_next.",\n"
		."\"attack_w_p\": ".array_search("attack_w",array_keys($achievements)).",\n"
		."\"missions_c\": ".$missions.",\n"
		."\"missions_a\": ".$missions_next.",\n"
		."\"missions_p\": ".array_search("missions",array_keys($achievements)).",\n"
		."\"logins_c\": ".$logins.",\n"
		."\"logins_a\": ".$logins_next.",\n"
		."\"logins_p\": ".array_search("logins",array_keys($achievements)).",\n"
		."\"loyal_c\": ".$loyal.",\n"
		."\"loyal_a\": ".$loyal_next.",\n"
		."\"loyal_p\": ".array_search("loyal",array_keys($achievements)).",\n"
		."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>