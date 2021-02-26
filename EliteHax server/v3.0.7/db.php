<?php
	try {
		//GitHub Note: You need to put the right db password
		$db = new PDO('mysql:host=localhost;dbname=elitehax;charset=utf8mb4', 'elitehax_dba', '<DBPASSWORD>',array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8") );
		$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		$db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>