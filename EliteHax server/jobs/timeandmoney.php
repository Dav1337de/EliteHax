<?php
function getTime($type,$lvl,$internet,$cpu) {
	if (($type == 'exploit') or ($type == 'malware')) {
		//TOGLIERE *0.4 DOPO BETA
		$part1=30*(11-$internet)*(6-($cpu/2));
		$part2=((log($lvl,2) / 0.8)*$lvl);
		$time = ceil((30*(11-$internet)*(6-($cpu/2)) + ((log($lvl,2) / 0.8)*$lvl))*0.7);
	}
	elseif (($type == 'internet') or ($type == 'cpu') or ($type == 'ram') or ($type == 'hdd') or ($type == 'c2c') or ($type == 'fan') or ($type == 'cryptominer')) {
		//$money = ceil(600 + (log($lvl,1.0006)*$lvl));
		$part1 = 1000;
		$part2 = log($lvl,2)*$lvl;
		$time = ceil(1000*log($lvl,2)*$lvl);
	}
	else {
		$part1 = 10*(11-$internet)*(6-($cpu/2));
		$part2 = ((log($lvl,2) / 1.7)*$lvl);
		$time = ceil((10*(11-$internet)*(6-($cpu/2)) + ((log($lvl,2) / 1.7)*$lvl))*0.7);
	}
	return array($part1,$part2,$time);
}

function getMoney($type,$lvl) {
	if (($type == 'exploit') or ($type == 'malware')) {
		$money = ceil(300 + (log($lvl,1.006)*$lvl));
	}
	elseif (($type == 'internet') or ($type == 'cpu') or ($type == 'ram') or ($type == 'hdd') or ($type == 'c2c') or ($type == 'fan') or ($type == 'cryptominer')) {
		//$money = ceil(600 + (log($lvl,1.0006)*$lvl));
		$money = ceil(pow(($lvl-1),3)*150000);
	}
	else {
		$money = ceil(100 + (log($lvl,1.0115)*$lvl));
	}
	return $money;
}

function getPoints($type,$lvl) {
	if (($type == 'exploit') or ($type == 'malware')) {
		$points = 5;
	}
	elseif (($type == 'internet') or ($type == 'cpu') or ($type == 'ram') or ($type == 'hdd') or ($type == 'c2c') or ($type == 'fan') or ($type == 'cryptominer')) {
		$points = $lvl*50;
	}	
	else {
		$points = 3;
	}
	return $points;
}

function mission_duration($difficult) {
	if ($difficult == 1) { $duration = random_int(40,80); }
	elseif ($difficult == 2) { $duration = random_int(100,140); }
	elseif ($difficult == 3) { $duration = random_int(240,360); }
	elseif ($difficult == 4) { $duration = random_int(600,720); }
	elseif ($difficult == 5) { $duration = random_int(1200,1440); }
	return $duration;
}

function mission_reward($difficult,$gpu) {
	if ($difficult == 1) { 
		if ($gpu<=1000) {
			$reward = random_int(500,600)*$gpu; 
		}
		elseif ($gpu<=2500) {
			$reward = (random_int(500,600)*1000)+(random_int(500,600)*($gpu-1000)*0.75);
		}
		elseif ($gpu<=5000) {
			$reward = (random_int(500,600)*1000)+(random_int(500,600)*1500*0.75)+(random_int(500,600)*($gpu-2500)*0.65);
		}
		elseif ($gpu<=7500) {
			$reward = (random_int(500,600)*1000)+(random_int(500,600)*1500*0.75)+(random_int(500,600)*2500*0.65)+(random_int(500,600)*($gpu-5000)*0.35);
		}
		elseif ($gpu<=10000) {
			$reward = (random_int(500,600)*1000)+(random_int(500,600)*1500*0.75)+(random_int(500,600)*2500*0.65)+(random_int(500,600)*2500*0.35)+(random_int(500,600)*($gpu-7500)*0.25);
		}
		else {
			$reward = (random_int(500,600)*1000)+(random_int(500,600)*1500*0.75)+(random_int(500,600)*2500*0.65)+(random_int(500,600)*2500*0.35)+(random_int(500,600)*2500*0.25)+(random_int(500,600)*($gpu-10000)*0.15);
		}
	}
	elseif ($difficult == 2) {
		if ($gpu<=1000) {
			$reward = random_int(1000,1200)*$gpu; 
		}
		elseif ($gpu<=2500) {
			$reward = (random_int(1000,1200)*1000)+(random_int(1000,1200)*($gpu-1000)*0.75);
		}
		elseif ($gpu<=5000) {
			$reward = (random_int(1000,1200)*1000)+(random_int(1000,1200)*1500*0.75)+(random_int(1000,1200)*($gpu-2500)*0.65);
		}
		elseif ($gpu<=7500) {
			$reward = (random_int(1000,1200)*1000)+(random_int(1000,1200)*1500*0.75)+(random_int(1000,1200)*2500*0.65)+(random_int(1000,1200)*($gpu-5000)*0.35);
		}
		elseif ($gpu<=10000) {
			$reward = (random_int(1000,1200)*1000)+(random_int(1000,1200)*1500*0.75)+(random_int(1000,1200)*2500*0.65)+(random_int(1000,1200)*2500*0.35)+(random_int(1000,1200)*($gpu-7500)*0.25);
		}
		else {
			$reward = (random_int(1000,1200)*1000)+(random_int(1000,1200)*1500*0.75)+(random_int(1000,1200)*2500*0.65)+(random_int(1000,1200)*2500*0.35)+(random_int(1000,1200)*2500*0.25)+(random_int(1000,1200)*($gpu-10000)*0.15);
		}
	}
	elseif ($difficult == 3) {
		if ($gpu<=1000) {
			$reward = random_int(2000,2500)*$gpu; 
		}
		elseif ($gpu<=2500) {
			$reward = (random_int(2000,2500)*1000)+(random_int(2000,2500)*($gpu-1000)*0.75);
		}
		elseif ($gpu<=5000) {
			$reward = (random_int(2000,2500)*1000)+(random_int(2000,2500)*1500*0.75)+(random_int(2000,2500)*($gpu-2500)*0.65);
		}
		elseif ($gpu<=7500) {
			$reward = (random_int(2000,2500)*1000)+(random_int(2000,2500)*1500*0.75)+(random_int(2000,2500)*2500*0.65)+(random_int(2000,2500)*($gpu-5000)*0.35);
		}
		elseif ($gpu<=10000) {
			$reward = (random_int(2000,2500)*1000)+(random_int(2000,2500)*1500*0.75)+(random_int(2000,2500)*2500*0.65)+(random_int(2000,2500)*2500*0.35)+(random_int(2000,2500)*($gpu-7500)*0.25);
		}
		else {
			$reward = (random_int(2000,2500)*1000)+(random_int(2000,2500)*1500*0.75)+(random_int(2000,2500)*2500*0.65)+(random_int(2000,2500)*2500*0.35)+(random_int(2000,2500)*2500*0.25)+(random_int(2000,2500)*($gpu-10000)*0.15);
		}
	}
	elseif ($difficult == 4) {
		if ($gpu<=1000) {
			$reward = random_int(5000,6000)*$gpu; 
		}
		elseif ($gpu<=2500) {
			$reward = (random_int(5000,6000)*1000)+(random_int(5000,6000)*($gpu-1000)*0.75);
		}
		elseif ($gpu<=5000) {
			$reward = (random_int(5000,6000)*1000)+(random_int(5000,6000)*1500*0.75)+(random_int(5000,6000)*($gpu-2500)*0.65);
		}
		elseif ($gpu<=7500) {
			$reward = (random_int(5000,6000)*1000)+(random_int(5000,6000)*1500*0.75)+(random_int(5000,6000)*2500*0.65)+(random_int(5000,6000)*($gpu-5000)*0.35);
		}
		elseif ($gpu<=10000) {
			$reward = (random_int(5000,6000)*1000)+(random_int(5000,6000)*1500*0.75)+(random_int(5000,6000)*2500*0.65)+(random_int(5000,6000)*2500*0.35)+(random_int(5000,6000)*($gpu-7500)*0.25);
		}
		else {
			$reward = (random_int(5000,6000)*1000)+(random_int(5000,6000)*1500*0.75)+(random_int(5000,6000)*2500*0.65)+(random_int(5000,6000)*2500*0.35)+(random_int(5000,6000)*2500*0.25)+(random_int(5000,6000)*($gpu-10000)*0.15);
		}
	}
	elseif ($difficult == 5) { 
		if ($gpu<=1000) {
			$reward = random_int(10000,12000)*$gpu; 
		}
		elseif ($gpu<=2500) {
			$reward = (random_int(10000,12000)*1000)+(random_int(10000,12000)*($gpu-1000)*0.75);
		}
		elseif ($gpu<=5000) {
			$reward = (random_int(10000,12000)*1000)+(random_int(10000,12000)*1500*0.75)+(random_int(10000,12000)*($gpu-2500)*0.65);
		}
		elseif ($gpu<=7500) {
			$reward = (random_int(10000,12000)*1000)+(random_int(10000,12000)*1500*0.75)+(random_int(10000,12000)*2500*0.65)+(random_int(10000,12000)*($gpu-5000)*0.35);
		}
		elseif ($gpu<=10000) {
			$reward = (random_int(10000,12000)*1000)+(random_int(10000,12000)*1500*0.75)+(random_int(10000,12000)*2500*0.65)+(random_int(10000,12000)*2500*0.35)+(random_int(10000,12000)*($gpu-7500)*0.25);
		}
		else {
			$reward = (random_int(10000,12000)*1000)+(random_int(10000,12000)*1500*0.75)+(random_int(10000,12000)*2500*0.65)+(random_int(10000,12000)*2500*0.35)+(random_int(10000,12000)*2500*0.25)+(random_int(10000,12000)*($gpu-10000)*0.15);
		}
	}
	return $reward;
}

function mission_xp($difficult) {
	if ($difficult == 1) { $xp = random_int(10,15); }
	elseif ($difficult == 2) { $xp = random_int(25,30); }
	elseif ($difficult == 3) { $xp = random_int(40,45); }
	elseif ($difficult == 4) { $xp = random_int(55,60); }
	elseif ($difficult == 5) { $xp = random_int(70,75); }
	return $xp;
}

function max_missions($mc_lvl) {
	if ($mc_lvl == 1) { $max_missions = 1; }
	elseif ($mc_lvl == 2) { $max_missions = 1; }
	elseif ($mc_lvl == 3) { $max_missions = 2; }
	elseif ($mc_lvl == 4) { $max_missions = 2; }
	elseif ($mc_lvl == 5) { $max_missions = 3; }
	return $max_missions;
}

function mc_upgrade_cost($mc_lvl) {
	if ($mc_lvl == 1) { $mc_upgrade_cost = 5000; }
	elseif ($mc_lvl == 2) { $mc_upgrade_cost = 100000; }
	elseif ($mc_lvl == 3) { $mc_upgrade_cost = 1000000; }
	elseif ($mc_lvl == 4) { $mc_upgrade_cost = 10000000; }
	return $mc_upgrade_cost;
}

function openPack($type) {
	if ($type == "sp") {
		$rtype = random_int(1,15);
		if ($rtype <= 1) {
			$amount = random_int(500000,1000000);
		}
		elseif ($rtype == 2) {
			$amount = random_int(750000,1250000);
		}
		elseif (($rtype >= 3) and ($rtype <= 14)) {
			$amount = random_int(5,10);
		}
		elseif ($rtype == 15) {
			$amount = random_int(2,4);
		}
	}
	if ($type == "mp") {
		$rtype = random_int(1,16);
		if ($rtype <= 1) {
			$amount = random_int(750000,1500000);
		}
		elseif ($rtype == 2) {
			$amount = random_int(1500000,3000000);
		}
		elseif (($rtype >= 3) and ($rtype <= 14)) {
			$amount = random_int(10,20);
		}
		elseif ($rtype == 15) {
			$amount = random_int(5,7);
		}
		elseif ($rtype == 16) {
			$amount = random_int(20,30)*10;
		}
	}
	if ($type == "lp") {
		$rtype = random_int(1,19);
		//Money
		if ($rtype <= 1) {
			$amount = random_int(3000000,8000000);
		}
		elseif ($rtype == 2) {
			$amount = random_int(5000000,10000000);
		}
		//Upgrades
		elseif (($rtype >= 3) and ($rtype <= 14)) {
			$amount = random_int(20,35);
		}
		//Overclock
		elseif ($rtype == 15) {
			$amount = random_int(9,13);
		}
		//Cryptocoins
		elseif ($rtype == 16) {
			$amount = random_int(40,60)*10;
		}
		//Small Packs
		elseif ($rtype == 17) {
			$amount = random_int(5,8);
		}
		//Medium Packs
		elseif ($rtype == 18) {
			$amount = random_int(3,5);
		}
		//Large Packs
		elseif ($rtype == 19) {
			$amount = 2;
		}
	}
	return array($rtype,$amount);
}

function openOverclockPack($type) {
	if ($type == "so") {
		$amount = random_int(1,3);
	}
	if ($type == "mo") {
		$amount = random_int(4,6);
	}
	if ($type == "lo") {
		$amount = random_int(8,12);
	}
	return $amount;
}

function openMoneyPack($type) {
	if ($type == "sm") {
		$amount = random_int(1000000,2000000);
	}
	if ($type == "mm") {
		$amount = random_int(2500000,5000000);
	}
	if ($type == "lm") {
		$amount = random_int(7500000,12500000);
	}
	return $amount;
}

function getDailyReward($days) {
	if ($days <= 7) {
		$reward = random_int(1,3);
	}
	elseif ($days <= 14) {
		$reward = random_int(1,6);
	}
	elseif ($days <= 21) {
		$reward = random_int(1,9);
	}
	elseif ($days <= 30) {
		$reward = random_int(4,9);
	}
	else $reward = random_int(1,100);
	
	//Reward 1-30 days
	if ($days <= 30) {
		if ($reward == 1) { $reward_name = "small_packs"; }
		elseif ($reward == 2) { $reward_name = "small_money"; }
		elseif ($reward == 3) { $reward_name = "small_oc_packs"; }
		elseif ($reward == 4) { $reward_name = "medium_packs"; }
		elseif ($reward == 5) { $reward_name = "medium_money"; }
		elseif ($reward == 6) { $reward_name = "medium_oc_packs"; }
		elseif ($reward == 7) { $reward_name = "large_packs"; }
		elseif ($reward == 8) { $reward_name = "large_money"; }
		elseif ($reward == 9) { $reward_name = "large_oc_packs"; }
	}
	else {
		if ($reward <= 14) { $reward_name = "medium_money"; }
		elseif ($reward <= 30) { $reward_name = "medium_packs"; }
		elseif ($reward <= 46) { $reward_name = "medium_oc_packs"; }
		elseif ($reward <= 62) { $reward_name = "large_money"; }
		elseif ($reward <= 78) { $reward_name = "large_packs"; }
		elseif ($reward <= 94) { $reward_name = "large_oc_packs"; }
		elseif ($reward <= 98) { $reward_name = "ip_change"; }
		elseif ($reward <= 100) { $reward_name = "skill_tree_reset"; }
	}
	return $reward_name;
}

function sommatoria($num) {
    $res = 250;
	$multiplier=250;
	
	if ($num==1) { $res=0; }
    for ($i=2;$i<=$num;$i++) { 
		if ($i>=20) { $multiplier=200; }
		if ($i>=40) { $multiplier=150; }
		$res=$res+($i-1)*$multiplier-$multiplier;
	}
    return $res;
}

function getNextLevel($type,$cur) {
	if (($type=="internet") or ($type=="cpu") or ($type=="c2c") or ($type=="ram") or ($type=="hdd") or ($type=="fan")) {
		$result=$cur+2;
	}
	elseif (($type=="gpu") or ($type=="firewall") or ($type=="ips") or ($type=="av") or ($type=="malware") or ($type=="exploit") or ($type=="siem") or ($type=="anon") or ($type=="webs") or ($type=="apps") or ($type=="dbs") or ($type=="scan") or ($type=="attack_w")) {
		if ($cur==0) { $result=10; }
		elseif ($cur==1) { $result=50; }
		elseif ($cur==2) { $result=100; }
		elseif ($cur==3) { $result=250; }
		elseif ($cur==4) { $result=500; }
		elseif ($cur==5) { $result=1000; }
		elseif ($cur==6) { $result=2500; }
		elseif ($cur==7) { $result=5000; }
		elseif ($cur==8) { $result=10000; }
		else { $result=10001; }
	}
	elseif ($type=="missions") {
		if ($cur==0) { $result=10; }
		elseif ($cur==1) { $result=25; }
		elseif ($cur==2) { $result=50; }
		elseif ($cur==3) { $result=100; }
		elseif ($cur==4) { $result=250; }
		elseif ($cur==5) { $result=500; }
		elseif ($cur==6) { $result=1000; }
		elseif ($cur==7) { $result=2500; }
		elseif ($cur==8) { $result=5000; }
		else { $result=5001; }
	}
	elseif ($type=="max_activity") {
		if ($cur==0) { $result=3; }
		elseif ($cur==1) { $result=5; }
		elseif ($cur==2) { $result=10; }
		elseif ($cur==3) { $result=15; }
		elseif ($cur==4) { $result=20; }
		elseif ($cur==5) { $result=30; }
		elseif ($cur==6) { $result=40; }
		elseif ($cur==7) { $result=50; }
		elseif ($cur==8) { $result=60; }
		else { $result=61; }
	}
	elseif ($type=="videos") {
		if ($cur==0) { $result=5; }
		elseif ($cur==1) { $result=10; }
		elseif ($cur==2) { $result=25; }
		elseif ($cur==3) { $result=50; }
		elseif ($cur==4) { $result=100; }
		elseif ($cur==5) { $result=200; }
		elseif ($cur==6) { $result=350; }
		elseif ($cur==7) { $result=500; }
		elseif ($cur==8) { $result=1000; }
		else { $result=1001; }
	}
	elseif ($type=="loyal") {
		if ($cur==0) { $result=10; }
		elseif ($cur==1) { $result=30; }
		elseif ($cur==2) { $result=60; }
		elseif ($cur==3) { $result=90; }
		elseif ($cur==4) { $result=120; }
		elseif ($cur==5) { $result=180; }
		elseif ($cur==6) { $result=240; }
		elseif ($cur==7) { $result=300; }
		elseif ($cur==8) { $result=365; }
		else { $result=366; }
	}
	return $result;
}
?>