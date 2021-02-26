<?php
	//Validate Crew Name
	if (!isset($_POST['crew_name']))
		exit("An Error occured!");
	$crew=trim($_POST['crew_name']);
	$chars = preg_match_all( "/[a-zA-Z0-9]/", $crew );
	if ($chars < 4) {
		return false;
	}
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\ ]/",$crew) or (strlen($crew)>18))
		exit("An Error occured!");
		
	//Validate Crew Tag
	if (!isset($_POST['crew_tag']))
		exit("An Error occured!");
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!]/",$_POST['crew_tag']) or (strlen($_POST['crew_tag'])>5))
		exit("An Error occured!");
		
	//Validate Crew Desc
	if (!isset($_POST['crew_desc']))
		exit("An Error occured!");
	if (preg_match("/[^a-zA-Z0-9\.\-\_\!\ ]/",$_POST['crew_desc']) or (strlen($_POST['crew_desc'])>35))
		exit("An Error occured!");

	include 'db.php';
	include 'validate.php';
	try {
		$id = getIdFromToken($db);
		//CHECK if user is not in a Crew
		$stmt = $db->prepare('SELECT crew FROM user WHERE user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			if ($row['crew'] != 0) { 
				exit("An Error occured!");
			}
		}
		//CHECK if Crew exists
		$stmt = $db->prepare('SELECT * FROM crew WHERE crew.name=? or crew.tag=?');
		$stmt->bindValue(1, $crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['crew_tag'], PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if (strcasecmp($row['name'],$crew) == 0) { exit(base64_encode("{\n\"status\": \"NE\"\n}")); }
			if (strcasecmp($row['tag'],$_POST['crew_tag']) == 0) { exit(base64_encode("{\n\"status\": \"TE\"\n}")); }
		}			
		//CHECK Money
		$stmt = $db->prepare('SELECT money FROM user WHERE user.id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
			if ($row['money'] < 1000000) {
				exit("An Error occured!");
			}
		}
		//Create Crew
		$stmt = $db->prepare('INSERT INTO crew (name, tag, description,slot,wallet_p) VALUES (?,?,?,10,5)');
		$stmt->bindValue(1, $crew, PDO::PARAM_INT);
		$stmt->bindValue(2, $_POST['crew_tag'], PDO::PARAM_INT);
		$stmt->bindValue(3, $_POST['crew_desc'], PDO::PARAM_INT);
		$stmt->execute();
		//Insert user into Crew as Leader and remove 1M
		$crew_id = $db->lastInsertId();
		$stmt = $db->prepare('UPDATE user SET crew=?, crew_role=1, money=money-1000000 WHERE id=?');
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();
		//Remove other requests
		$stmt = $db->prepare('DELETE FROM crew_requests WHERE user_id=?');
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		//Create Datacenter
		$region=random_int(1, 18);
		$stmt = $db->prepare('INSERT INTO datacenter (crew_id, region, relocation,cpoints,timestamp) VALUES (?,?,1,0,NOW())');
		$stmt->bindValue(1, $crew_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $region, PDO::PARAM_INT);
		$stmt->execute();
		$dc_id = $db->lastInsertId();
		
		//Create Datacenter Upgrade
		$mf_prod=random_int(1,2);
		$stmt = $db->prepare('INSERT INTO datacenter_upgrades (datacenter_id,fwext,ips,siem,fwint1,fwint2,mf1,mf2,scanner,exploit,relocate,anon,mf_prod,mf1_testprod,mf2_testprod) VALUES (?,1,1,1,1,1,1,1,1,1,0,1,?,0,0)');
		$stmt->bindValue(1, $dc_id, PDO::PARAM_INT);
		$stmt->bindValue(2, $mf_prod, PDO::PARAM_INT);
		$stmt->execute();
		
		$resp = "{\n\"status\": \"OK\"\n}";			
		
		echo base64_encode($resp);
		//echo "<p>".$resp;
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>