<?php
	include 'db.php';
	try {
		echo "<html><head><title>Cheat Detector - Login IP</title></head><body>";
		
		$stmt = $db->prepare("SELECT username,login_ip,device_id,creation_time,last_login FROM `user` where login_ip=? ORDER BY id ASC");
		$stmt->bindValue(1, $_GET['login_ip'], PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Players by Login IP</h2><table>"
		."<td>Username</td>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Creation Time</td>"
		."<td>Last Login</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td>" . $row['username'] . "</td>";
			echo "<td>" . $row['login_ip'] . "</td>";
			echo "<td>" . $row['device_id'] . "</td>";
			echo "<td>" . $row['creation_time'] . "</td>";
			echo "<td>" . $row['last_login'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>