<?php
	include 'db.php';
	try {
		echo "<html><head><title>Cheat Detector - Login IP</title></head><body>";
		
		$stmt = $db->prepare("SELECT distinct username,login_audit.user_id,login_audit.ip,login_audit.device_id,login_audit.country,login_audit.isp FROM login_audit JOIN user on login_audit.user_id=user.id where login_audit.ip=? ORDER BY user.id ASC");
		$stmt->bindValue(1, $_GET['login_ip'], PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Players by Login IP</h2><table>"
		."<td>Username</td>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Country</td>"
		."<td>ISP</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['user_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['ip'] . "</td>";
			echo "<td><a href=\"sharedDeviceID.php?device_id=".$row['device_id']."\">".$row['device_id'] . "</a></td>";
			echo "<td>" . $row['country'] . "</td>";
			echo "<td>" . $row['isp'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>