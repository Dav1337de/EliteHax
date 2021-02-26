<?php
	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		$stmt = $db->prepare("SELECT black_pic,gray_pic,ghost_pic,pirate_pic,ninja_pic,anon_pic,cyborg_pic,wolf_pic,tiger_pic,gas_mask_pic FROM items_pay WHERE user_id=?"); 
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$bp = $row['black_pic'];
			$gp = $row['gray_pic'];
			$ghp = $row['ghost_pic'];
			$pp = $row['pirate_pic'];
			$np = $row['ninja_pic'];
			$ap = $row['anon_pic'];
			$cp = $row['cyborg_pic'];
			$wp = $row['wolf_pic'];
			$tp = $row['tiger_pic'];
			$gmp = $row['gas_mask_pic'];
		}
		
		$resp = "{\n\"black_pic\": ".$bp.",\n"
		."\"gray_pic\": ".$gp.",\n"
		."\"ghost_pic\": ".$ghp.",\n"
		."\"pirate_pic\": ".$pp.",\n"
		."\"ninja_pic\": ".$np.",\n"
		."\"anon_pic\": ".$ap.",\n"
		."\"cyborg_pic\": ".$cp.",\n"
		."\"wolf_pic\": ".$wp.",\n"
		."\"tiger_pic\": ".$tp.",\n"
		."\"gas_mask_pic\": ".$gmp.",\n"
		."}";
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>