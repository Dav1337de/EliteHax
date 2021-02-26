<?php
	include 'db.php';
	try {
		echo "<html><head><title>Cheat Detector</title></head><body>";
		
		$stmt = $db->prepare("SELECT DISTINCT user_id,username FROM `login_audit` join user on login_audit.user_id=user.id where login_audit.anon='anon'");
		$stmt->execute();

		echo "<h2>Anonymizers</h2><table>"
		."<td>Username</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['user_id']."\">".$row['username'] . "</a></td>";
			echo "</tr>";
		}
		echo "</table>";
		
		$stmt = $db->prepare("SELECT user_id,username,count(DISTINCT country) as tot FROM `login_audit` join user on login_audit.user_id=user.id group by user_id having count(DISTINCT country)>1 order by count(DISTINCT country) desc");
		$stmt->execute();

		echo "<h2>Multiple Countries</h2><table>"
		."<td>Username</td>"
		."<td>Number of Countries</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['user_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['tot'] . "</td>";
			echo "</tr>";
		}
		echo "</table>";
		
		$stmt = $db->prepare("SELECT device_id,count(distinct user_id) as tot FROM `login_audit` group by device_id having count(distinct user_id)>1 order by count(distinct user_id) desc");
		$stmt->execute();

		echo "<h2>Shared Devices</h2><table>"
		."<td>Device ID</td>"
		."<td>Number of Users</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"sharedDeviceID.php?device_id=".$row['device_id']."\">".$row['device_id'] . "</a></td>";
			echo "<td>" . $row['tot'] . "</td>";
			echo "</tr>";
		}
		echo "</table>";
		
		$stmt = $db->prepare("SELECT ip,count(distinct user_id) as tot FROM `login_audit` group by ip having count(distinct user_id)>1 order by count(distinct user_id) desc");
		$stmt->execute();

		echo "<h2>Shared Login IP</h2><table>"
		."<td>Login IP</td>"
		."<td>Number of Users</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"sharedLoginIP.php?login_ip=".$row['ip']."\">".$row['ip'] . "</a></td>";
			echo "<td>" . $row['tot'] . "</td>";
			echo "</tr>";
		}
		echo "</table>";
		
		$stmt = $db->prepare("SELECT attacker_id,username,timestamp,count(attack_log.id) as tot FROM `attack_log` JOIN user ON attack_log.attacker_id=user.id GROUP BY attacker_id,DAY(timestamp),HOUR(timestamp),MINUTE(timestamp) HAVING count(attack_log.id)>35 ORDER BY count(attack_log.id) DESC LIMIT 100");
		$stmt->execute();

		echo "<h2>Abnormal Attack Rate</h2><table>"
		."<td>Username</td>"
		."<td>Timestamp</td>"
		."<td>Attacks per minute</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['attacker_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['timestamp'] . "</td>";
			echo "<td>" . $row['tot'] . "</td>";
			echo "</tr>";
		}
		echo "</table>";
		
		$stmt = $db->prepare("SELECT username,attacker_id,day,count(hour) as hour FROM (SELECT attacker_id,MONTH(timestamp) as month,DAY(timestamp) as day,HOUR(timestamp) as hour FROM `attack_log` group by MONTH(timestamp),DAY(timestamp),hour(timestamp),attacker_id) as t JOIN user ON t.attacker_id=user.id group by day,attacker_id having count(hour)>16 ORDER BY count(hour) DESC");
		$stmt->execute();

		echo "<h2>Abnormal Daily Activity</h2><table>"
		."<td>Username</td>"
		."<td>Day</td>"
		."<td>Hours of activity</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['attacker_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['day'] . "</td>";
			echo "<td>" . $row['hour'] . "</td>";
			echo "</tr>";
		}
		echo "</table>";
		
		$stmt = $db->prepare("SELECT id,username,login_ip,device_id,count(id) as tot FROM `user` where device_id<>'' group by device_id having count(id)>2 ORDER BY count(id) DESC");
		$stmt->execute();

		echo "<h2>Players by Device ID</h2><table>"
		."<td>Username</td>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Number of device</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['login_ip'] . "</td>";
			echo "<td><a href=\"cheatDeviceID.php?device_id=".$row['device_id']."\">".$row['device_id'] . "</a></td>";
			echo "<td>" . $row['tot'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
		$stmt = $db->prepare("SELECT id,username,login_ip,device_id,count(id) as tot FROM `user` where device_id<>'' group by login_ip having count(id)>2 ORDER BY count(id) DESC");
		$stmt->execute();

		echo "<h2>Players by Login IP</h2><table>"
		."<td>Username</td>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Number of device</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['id']."\">".$row['username'] . "</a></td>";
			echo "<td><a href=\"cheatLoginIP.php?login_ip=".$row['login_ip']."\">".$row['login_ip'] . "</a></td>";
			echo "<td>" . $row['device_id'] . "</td>";
			echo "<td>" . $row['tot'] . "</td>";
			echo "</tr>";
		}
		echo "</table>";
		echo "</body>";

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>