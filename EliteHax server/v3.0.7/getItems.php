<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT uuid, cryptocoins, new_cryptocoins, videos, money, username, small_packs, medium_packs, large_packs, small_money, medium_money, large_money, small_oc_packs, medium_oc_packs, large_oc_packs, ip_change, skill_tree_reset FROM user JOIN items ON user.id=items.user_id WHERE user.id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$uuid = $row['uuid'];
			$cryptocoins = $row['cryptocoins'];
			$new_cryptocoins = $row['new_cryptocoins'];
			$money = $row['money'];
			$username = $row['username'];
			$sp = $row['small_packs'];
			$mp = $row['medium_packs'];
			$lp = $row['large_packs'];
			$sm = $row['small_money'];
			$mm = $row['medium_money'];
			$lm = $row['large_money'];
			$ip_change = $row['ip_change'];
			$st_reset = $row['skill_tree_reset'];
			$small_oc_packs = $row['small_oc_packs'];
			$medium_oc_packs = $row['medium_oc_packs'];
			$large_oc_packs = $row['large_oc_packs'];
		}
		
		$resp = "{\n\"status\": \"OK\",\n"
				."\"id\": \"".$uuid."\",\n"
				."\"username\": \"".$username."\",\n"
				."\"sp\": \"".$sp."\",\n"
				."\"mp\": \"".$mp."\",\n"
				."\"lp\": \"".$lp."\",\n"
				."\"sm\": \"".$sm."\",\n"
				."\"mm\": \"".$mm."\",\n"
				."\"lm\": \"".$lm."\",\n"
				."\"money\": \"".$money."\",\n"
				."\"cc\": \"".$cryptocoins."\",\n"
				."\"small_oc_packs\": \"".$small_oc_packs."\",\n"
				."\"medium_oc_packs\": \"".$medium_oc_packs."\",\n"
				."\"large_oc_packs\": \"".$large_oc_packs."\",\n"
				."\"ip_change\": \"".$ip_change."\",\n"
				."\"st_reset\": \"".$st_reset."\",\n"
				."\"new_cryptocoins\": \"".$new_cryptocoins."\"\n}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>