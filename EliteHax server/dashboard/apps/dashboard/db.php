<?php
	try {
		$db = new PDO('mysql:host=localhost;dbname=elitehax;charset=utf8mb4', 'elitehax_dba', '1FAKucwfs8c8BycWHbvq');
		$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		$db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
	} catch(PDOException $ex) {
		echo "An Error occured!";
	}
?>