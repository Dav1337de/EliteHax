<?php
	try {
		//GitHub Note: You need to put the right db password
		$db = new PDO('mysql:host=localhost;dbname=elitehax;charset=utf8mb4', 'elitehax_dba', '<DBPASSWORD>');
		$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		$db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>