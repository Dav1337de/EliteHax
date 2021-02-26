<?php
	include 'db.php';
	include 'validate.php';
	include 'timeandmoney.php';
	if (!isset($_POST['type']) or !isset($_POST['qty']))
		exit("");
	$qty = $_POST['qty'];
	if (!is_numeric($qty))
		exit("");
	if ($qty < 1) 
		exit("");
	$type = $_POST['type'];
	$whitelist = Array( 'sp', 'mp', 'lp', 'sm', 'mm', 'lm', 'so', 'mo', 'lo' );
	if( !in_array( $type, $whitelist ) )
		exit("");
	try {
		$id = getIdFromToken($db);		
		$stmt = $db->prepare("SELECT cryptocoins, money, username, small_packs, medium_packs, large_packs, small_money, medium_money, large_money, small_oc_packs, medium_oc_packs, large_oc_packs, ip_change, skill_tree_reset FROM user JOIN items ON user.id=items.user_id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$cryptocoins = $row['cryptocoins'];
			$money = $row['money'];
			$username = $row['username'];
			$sp = $row['small_packs'];
			$mp = $row['medium_packs'];
			$lp = $row['large_packs'];
			$sm = $row['small_money'];
			$mm = $row['medium_money'];
			$lm = $row['large_money'];
			$so = $row['small_oc_packs'];
			$mo = $row['medium_oc_packs'];
			$lo = $row['large_oc_packs'];
			$ip_change = $row['ip_change'];
			$st_reset = $row['skill_tree_reset'];
		}
		$amount_arr = array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
		if ((($type == "sp") and ($qty<=$sp)) or (($type == "mp") and ($qty<=$mp)) or (($type == "lp") and ($qty<=$lp))) {
			for ($i = 1; $i <= $qty; $i++) {
				$res = openPack($type);
				$rtype = $res[0]-1;
				$amount = $res[1];
				$amount_arr[$rtype] = $amount_arr[$rtype]+$amount;
			}
			if ($type == "sp") { 
				$typet = "small_packs"; 
				$sp = $sp-$qty;
			}
			elseif ($type == "mp") { 
				$typet = "medium_packs"; 
				$mp = $mp-$qty;
			}
			elseif ($type == "lp") { 
				$typet = "large_packs";
				$lp = $lp-$qty;
			}
			
			//Remove opened packs
			$stmt = $db->prepare("UPDATE items SET {$typet}={$typet}-? WHERE user_id=?"); 
			$stmt->bindValue(1, $qty, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			//Get rewards
			$new_money = $amount_arr[0]+$amount_arr[1];
			$siem = $amount_arr[2];
			$firewall = $amount_arr[3];
			$ips = $amount_arr[4];
			$anon = $amount_arr[5];
			$webs = $amount_arr[6];
			$apps = $amount_arr[7];
			$dbs = $amount_arr[8];
			$gpu = $amount_arr[9];
			$av = $amount_arr[10];
			$malware = $amount_arr[11];
			$exploit = $amount_arr[12];
			$scan = $amount_arr[13];
			$overclock = $amount_arr[14];
			$new_cc = $amount_arr[15];
			$new_sp = $amount_arr[16];
			$new_mp = $amount_arr[17];
			$new_lp = $amount_arr[18];
			
			//Update Money (0-3)
			$stmt = $db->prepare("UPDATE user SET money=money+? WHERE id=?"); 
			$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$money=$money+$new_money;
			
			//Update Upgrades (4-15)
			$stmt = $db->prepare("UPDATE upgrades SET siem=siem+?,firewall=firewall+?,ips=ips+?,anon=anon+?,webs=webs+?,apps=apps+?,dbs=dbs+?,gpu=gpu+?,av=av+?,malware=malware+?,exploit=exploit+?,scan=scan+? WHERE id=?"); 
			$stmt->bindValue(1, $siem, PDO::PARAM_INT);
			$stmt->bindValue(2, $firewall, PDO::PARAM_INT);
			$stmt->bindValue(3, $ips, PDO::PARAM_INT);
			$stmt->bindValue(4, $anon, PDO::PARAM_INT);
			$stmt->bindValue(5, $webs, PDO::PARAM_INT);
			$stmt->bindValue(6, $apps, PDO::PARAM_INT);
			$stmt->bindValue(7, $dbs, PDO::PARAM_INT);
			$stmt->bindValue(8, $gpu, PDO::PARAM_INT);
			$stmt->bindValue(9, $av, PDO::PARAM_INT);
			$stmt->bindValue(10, $malware, PDO::PARAM_INT);
			$stmt->bindValue(11, $exploit, PDO::PARAM_INT);
			$stmt->bindValue(12, $scan, PDO::PARAM_INT);
			$stmt->bindValue(13, $id, PDO::PARAM_INT);
			$stmt->execute();
			//Handle running tasks
			if ($siem>0) {
				$stmt = $db->prepare("UPDATE upgrades SET siem_task=siem WHERE id=? and siem_task < siem"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='siem' and lvl<=(SELECT siem FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($firewall>0) {
				$stmt = $db->prepare("UPDATE upgrades SET firewall_task=firewall WHERE id=? and firewall_task < firewall"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='firewall' and lvl<=(SELECT firewall FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($ips>0) {
				$stmt = $db->prepare("UPDATE upgrades SET ips_task=ips WHERE id=? and ips_task < ips"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='ips' and lvl<=(SELECT ips FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($anon>0) {
				$stmt = $db->prepare("UPDATE upgrades SET anon_task=anon WHERE id=? and anon_task < anon"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='anon' and lvl<=(SELECT anon FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($webs>0) {
				$stmt = $db->prepare("UPDATE upgrades SET webs_task=webs WHERE id=? and webs_task < webs"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='webs' and lvl<=(SELECT webs FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($apps>0) {
				$stmt = $db->prepare("UPDATE upgrades SET apps_task=apps WHERE id=? and apps_task < apps"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='apps' and lvl<=(SELECT apps FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();					
			}
			if ($dbs>0) {
				$stmt = $db->prepare("UPDATE upgrades SET dbs_task=dbs WHERE id=? and dbs_task < dbs"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='dbs' and lvl<=(SELECT dbs FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($gpu>0) {
				$stmt = $db->prepare("UPDATE upgrades SET gpu_task=gpu WHERE id=? and gpu_task < gpu"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='gpu' and lvl<=(SELECT gpu FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($av>0) {
				$stmt = $db->prepare("UPDATE upgrades SET av_task=av WHERE id=? and av_task < av"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='av' and lvl<=(SELECT av FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($malware>0) {
				$stmt = $db->prepare("UPDATE upgrades SET malware_task=malware WHERE id=? and malware_task < malware"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='malware' and lvl<=(SELECT malware FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($exploit>0) {
				$stmt = $db->prepare("UPDATE upgrades SET exploit_task=exploit WHERE id=? and exploit_task < exploit"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='exploit' and lvl<=(SELECT exploit FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			if ($scan>0) {
				$stmt = $db->prepare("UPDATE upgrades SET scan_task=scan WHERE id=? and scan_task < scan"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->execute();	
				$stmt = $db->prepare("DELETE FROM task WHERE id=? and type='scan' and lvl<=(SELECT scan FROM upgrades WHERE id=?)"); 
				$stmt->bindValue(1, $id, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();	
			}
			//SCORE
			$new_score = ($siem*3)+($firewall*3)+($ips*3)+($anon*3)+($webs*3)+($apps*3)+($dbs*3)+($gpu*3)+($av*3)+($malware*5)+($exploit*5)+($scan*3);
			$stmt = $db->prepare("UPDATE user SET score=score+? WHERE id=?"); 
			$stmt->bindValue(1, $new_score, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			//UPDATE OVERCLOCK (16)
			if ($overclock>0) {
				$stmt = $db->prepare("UPDATE items SET overclock=overclock+? WHERE user_id=?"); 
				$stmt->bindValue(1, $overclock, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}	
			
			//UPDATE CRYPTOCOINS (17)
			if ($new_cc>0) {
				$stmt = $db->prepare("UPDATE user SET cryptocoins=cryptocoins+? WHERE id=?"); 
				$stmt->bindValue(1, $new_cc, PDO::PARAM_INT);
				$stmt->bindValue(2, $id, PDO::PARAM_INT);
				$stmt->execute();
			}
			
			//UPDATE PACKS (18-20)
			if (($new_sp>0) or ($new_mp>0) or ($new_lp>0)) {
				$stmt = $db->prepare("UPDATE items SET small_packs=small_packs+?,medium_packs=medium_packs+?,large_packs=large_packs+? WHERE user_id=?"); 
				$stmt->bindValue(1, $new_sp, PDO::PARAM_INT);
				$stmt->bindValue(2, $new_mp, PDO::PARAM_INT);
				$stmt->bindValue(3, $new_lp, PDO::PARAM_INT);
				$stmt->bindValue(4, $id, PDO::PARAM_INT);
				$stmt->execute();
				$sp=$sp+$new_sp;
				$mp=$mp+$new_mp;
				$lp=$lp+$new_lp;
			}
			
			$resp = "{\n\"status\": \"OK\",\n"
					."\"type\": \"".$type."\",\n"
					."\"sp\": \"".$sp."\",\n"
					."\"mp\": \"".$mp."\",\n"
					."\"lp\": \"".$lp."\",\n"
					."\"sm\": \"".$sm."\",\n"
					."\"mm\": \"".$mm."\",\n"
					."\"lm\": \"".$lm."\",\n"
					."\"small_oc_packs\": \"".$so."\",\n"
					."\"medium_oc_packs\": \"".$mo."\",\n"
					."\"large_oc_packs\": \"".$lo."\",\n"
					."\"ip_change\": \"".$ip_change."\",\n"
					."\"st_reset\": \"".$st_reset."\",\n"
					."\"money\": \"".$money."\",\n"
					."\"new_money\": \"".$new_money."\",\n"
					."\"siem\": \"".$siem."\",\n"
					."\"firewall\": \"".$firewall."\",\n"
					."\"ips\": \"".$ips."\",\n"
					."\"anon\": \"".$anon."\",\n"
					."\"webs\": \"".$webs."\",\n"
					."\"apps\": \"".$apps."\",\n"
					."\"dbs\": \"".$dbs."\",\n"
					."\"gpu\": \"".$gpu."\",\n"
					."\"av\": \"".$av."\",\n"
					."\"malware\": \"".$malware."\",\n"
					."\"exploit\": \"".$exploit."\",\n"
					."\"scan\": \"".$scan."\",\n"
					."\"new_cc\": \"".$new_cc."\",\n"
					."\"new_sp\": \"".$new_sp."\",\n"
					."\"new_mp\": \"".$new_mp."\",\n"
					."\"new_lp\": \"".$new_lp."\",\n"
					."\"overclock\": \"".$overclock."\",\n"
					."\"cc\": \"".($cryptocoins+$new_cc)."\"\n}";
			//echo $resp;
			echo base64_encode($resp);		
		}
		elseif ((($type == "sm") and ($qty<=$sm)) or (($type == "mm") and ($qty<=$mm)) or (($type == "lm") and ($qty<=$lm))) {
			$tot_amount=0;
			for ($i = 1; $i <= $qty; $i++) {
				$tot_amount = $tot_amount+openMoneyPack($type);
			}
			if ($type == "sm") { 
				$typet = "small_money"; 
				$sm = $sm-$qty;
			}
			elseif ($type == "mm") { 
				$typet = "medium_money"; 
				$mm = $mm-$qty;
			}
			elseif ($type == "lm") { 
				$typet = "large_money";
				$lm = $lm-$qty;
			}
			
			//Remove opened packs
			$stmt = $db->prepare("UPDATE items SET {$typet}={$typet}-? WHERE user_id=?"); 
			$stmt->bindValue(1, $qty, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			//Get rewards
			$new_money = $tot_amount;
			
			//Update Money
			$stmt = $db->prepare("UPDATE user SET money=money+? WHERE id=?"); 
			$stmt->bindValue(1, $new_money, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			$money=$money+$new_money;

			$resp = "{\n\"status\": \"OK\",\n"
				."\"type\": \"".$type."\",\n"
				."\"sp\": \"".$sp."\",\n"
				."\"mp\": \"".$mp."\",\n"
				."\"lp\": \"".$lp."\",\n"
				."\"sm\": \"".$sm."\",\n"
				."\"mm\": \"".$mm."\",\n"
				."\"lm\": \"".$lm."\",\n"
				."\"small_oc_packs\": \"".$so."\",\n"
				."\"medium_oc_packs\": \"".$mo."\",\n"
				."\"large_oc_packs\": \"".$lo."\",\n"
				."\"ip_change\": \"".$ip_change."\",\n"
				."\"st_reset\": \"".$st_reset."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"new_money\": \"".$new_money."\",\n}";
			//echo $resp;
			echo base64_encode($resp);	
		}
		elseif ((($type == "so") and ($qty<=$so)) or (($type == "mo") and ($qty<=$mo)) or (($type == "lo") and ($qty<=$lo))) {
			$tot_amount=0;
			for ($i = 1; $i <= $qty; $i++) {
				$tot_amount = $tot_amount+openOverclockPack($type);
			}
			if ($type == "so") { 
				$typet = "small_oc_packs"; 
				$so = $so-$qty;
			}
			elseif ($type == "mo") { 
				$typet = "medium_oc_packs"; 
				$mo = $mo-$qty;
			}
			elseif ($type == "lo") { 
				$typet = "large_oc_packs";
				$lo = $lo-$qty;
			}
			
			//Remove opened packs
			$stmt = $db->prepare("UPDATE items SET {$typet}={$typet}-? WHERE user_id=?"); 
			$stmt->bindValue(1, $qty, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();
			
			//Get rewards
			$new_overclock = $tot_amount;
			
			//Update Overclock
			$stmt = $db->prepare("UPDATE items SET overclock=overclock+? WHERE user_id=?"); 
			$stmt->bindValue(1, $new_overclock, PDO::PARAM_INT);
			$stmt->bindValue(2, $id, PDO::PARAM_INT);
			$stmt->execute();

			$resp = "{\n\"status\": \"OK\",\n"
				."\"type\": \"".$type."\",\n"
				."\"sp\": \"".$sp."\",\n"
				."\"mp\": \"".$mp."\",\n"
				."\"lp\": \"".$lp."\",\n"
				."\"sm\": \"".$sm."\",\n"
				."\"mm\": \"".$mm."\",\n"
				."\"lm\": \"".$lm."\",\n"
				."\"small_oc_packs\": \"".$so."\",\n"
				."\"medium_oc_packs\": \"".$mo."\",\n"
				."\"large_oc_packs\": \"".$lo."\",\n"
				."\"ip_change\": \"".$ip_change."\",\n"
				."\"st_reset\": \"".$st_reset."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"new_overclock\": \"".$new_overclock."\",\n}";
			//echo $resp;
			echo base64_encode($resp);	
		}

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>