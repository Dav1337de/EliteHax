<html><head><title>Cheat Detector - Device ID</title>
<style>
#customers {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

#customers td, #customers th {
    border: 1px solid #ddd;
    padding: 8px;
}

#customers tr:nth-child(even){background-color: #f2f2f2;}

#customers tr:hover {background-color: #ddd;}

#customers th {
    padding-top: 12px;
    padding-bottom: 12px;
    text-align: left;
    background-color: #4CAF50;
    color: white;
}
</style>
</head>
<body>
<?php
	include 'db.php';
	try {
		$id=$_GET[id];
		
		$stmt = $db->prepare("SELECT DISTINCT `ip`, `device_id`, `country`, `region`, `city`, `timezone`, `isp` FROM `login_audit` WHERE user_id=?");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Geolocations</h2><table>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Country</td>"
		."<td>Region</td>"
		."<td>City</td>"
		."<td>Timezone</td>"
		."<td>ISP</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"sharedLoginIP.php?login_ip=".$row['ip']."\">".$row['ip'] . "</a></td>";
			echo "<td><a href=\"sharedDeviceID.php?device_id=".$row['device_id']."\">".$row['device_id'] . "</a></td>";
			echo "<td>" . $row['country'] . "</td>";
			echo "<td>" . $row['region'] . "</td>";
			echo "<td>" . $row['city'] . "</td>";
			echo "<td>" . $row['timezone'] . "</td>";
			echo "<td>" . $row['isp'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
		$stmt = $db->prepare("SELECT id,username,login_ip,device_id,creation_time,last_login FROM `user` WHERE device_id=(SELECT device_id FROM user WHERE id=?) ORDER BY id ASC");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Players with same Device ID</h2><table id=\"customers\">"
		."<td>Username</td>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Creation Time</td>"
		."<td>Last Login</td>"
		."<td>Attacks</td>"
		."<td>Money Stolen</td>";
		for ($i=0;$i<24;$i++) {
			echo "<td>".$i."</td>";
		}
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$stmt2 = $db->prepare("SELECT count(id) as attacks,COALESCE(SUM(money_stolen),0) as money FROM attack_log WHERE (attacker_id=? and defense_id=?) or (attacker_id=? and defense_id=?)");
			$stmt2->bindValue(1, $id, PDO::PARAM_INT);
			$stmt2->bindValue(2, $row['id'], PDO::PARAM_INT);
			$stmt2->bindValue(3, $row['id'], PDO::PARAM_INT);
			$stmt2->bindValue(4, $id, PDO::PARAM_INT);
			$stmt2->execute();
			while($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {	
				$attacks=$row2['attacks'];
				$money=$row2['money'];
			}
			
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['login_ip'] . "</td>";
			echo "<td>" . $row['device_id'] . "</td>";
			echo "<td>" . $row['creation_time'] . "</td>";
			echo "<td>" . $row['last_login'] . "</td>";
			echo "<td>" . $attacks . "</td>";
			echo "<td>" . $money . "</td>";
			
			$stmt2 = $db->prepare("SELECT hour(timestamp)as hour,count(id) as attacks FROM `attack_log` WHERE attacker_id=? group by hour(timestamp)");
			$stmt2->bindValue(1, $row['id'], PDO::PARAM_INT);
			$stmt2->execute();
			$i=0;
			while($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {	
				for ($j=$i+1;$j<$row2['hour'];$j++) { 
					echo "<td></td>";
					$i=$j;
				}
				echo "<td>".$row2['attacks']."</td>";
				$i++;
			}
			for ($j=$i;$j<24;$j++) { 
				echo "<td></td>";
			}
			
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
		$stmt = $db->prepare("SELECT id,username,login_ip,device_id,creation_time,last_login FROM `user` where  login_ip=(SELECT login_ip FROM user WHERE id=?) ORDER BY id ASC");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->bindValue(2, $id, PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Players with same Login IP</h2><table id=\"customers\">"
		."<td>Username</td>"
		."<td>Login IP</td>"
		."<td>Device ID</td>"
		."<td>Creation Time</td>"
		."<td>Last Login</td>"
		."<td>Attacks</td>"
		."<td>Money Stolen</td>";
		for ($i=0;$i<24;$i++) {
			echo "<td>".$i."</td>";
		}
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			$stmt2 = $db->prepare("SELECT count(id) as attacks,COALESCE(SUM(money_stolen),0) as money FROM attack_log WHERE (attacker_id=? and defense_id=?) or (attacker_id=? and defense_id=?)");
			$stmt2->bindValue(1, $id, PDO::PARAM_INT);
			$stmt2->bindValue(2, $row['id'], PDO::PARAM_INT);
			$stmt2->bindValue(3, $row['id'], PDO::PARAM_INT);
			$stmt2->bindValue(4, $id, PDO::PARAM_INT);
			$stmt2->execute();
			while($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {	
				$attacks=$row2['attacks'];
				$money=$row2['money'];
			}
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['login_ip'] . "</td>";
			echo "<td>" . $row['device_id'] . "</td>";
			echo "<td>" . $row['creation_time'] . "</td>";
			echo "<td>" . $row['last_login'] . "</td>";
			echo "<td>" . $attacks . "</td>";
			echo "<td>" . $money . "</td>";
			
			$stmt2 = $db->prepare("SELECT hour(timestamp)as hour,count(id) as attacks FROM `attack_log` WHERE attacker_id=? group by hour(timestamp)");
			$stmt2->bindValue(1, $row['id'], PDO::PARAM_INT);
			$stmt2->execute();
			$i=0;
			while($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {	
				for ($j=$i+1;$j<$row2['hour'];$j++) { 
					echo "<td></td>";
					$i=$j;
				}
				echo "<td>".$row2['attacks']."</td>";
				$i++;
			}
			for ($j=$i;$j<24;$j++) { 
				echo "<td></td>";
			}
			
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
		$stmt = $db->prepare("SELECT defense_id,username,count(attack_log.id) as attacks,COALESCE(sum(money_stolen),0) as money FROM `attack_log` JOIN user ON attack_log.defense_id=user.id WHERE attacker_id=? group by defense_id order by count(attack_log.id) desc limit 10");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Top Targets by Attacks</h2><table id=\"customers\">"
		."<td>Username</td>"
		."<td>Attacks</td>"
		."<td>Money</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['defense_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['attacks'] . "</td>";
			echo "<td>" . $row['money'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";

		$stmt = $db->prepare("SELECT defense_id,username,count(attack_log.id) as attacks,COALESCE(sum(money_stolen),0) as money FROM `attack_log` JOIN user ON attack_log.defense_id=user.id WHERE attacker_id=? group by defense_id order by COALESCE(SUM(money_stolen),0) desc limit 10");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();

		echo "<h2>Top Targets by Money Stolen</h2><table id=\"customers\">"
		."<td>Username</td>"
		."<td>Attacks</td>"
		."<td>Money</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['defense_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['attacks'] . "</td>";
			echo "<td>" . $row['money'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
		$stmt = $db->prepare("SELECT attacker_id,username,count(attack_log.id) as attacks,COALESCE(sum(money_stolen),0) as money FROM `attack_log` JOIN user ON attack_log.attacker_id=user.id WHERE defense_id=? group by attacker_id order by count(attack_log.id) desc limit 10");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		echo "<h2>Top Attack Sources by Attacks</h2><table id=\"customers\">"
		."<td>Username</td>"
		."<td>Attacks</td>"
		."<td>Money</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['attacker_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['attacks'] . "</td>";
			echo "<td>" . $row['money'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";
		
		$stmt = $db->prepare("SELECT attacker_id,username,count(attack_log.id) as attacks,COALESCE(sum(money_stolen),0) as money FROM `attack_log` JOIN user ON attack_log.attacker_id=user.id WHERE defense_id=? group by attacker_id order by COALESCE(SUM(money_stolen),0) desc limit 10");
		$stmt->bindValue(1, $id, PDO::PARAM_INT);
		$stmt->execute();
		
		echo "<h2>Top Attack Sources by Money Stolen</h2><table id=\"customers\">"
		."<td>Username</td>"
		."<td>Attacks</td>"
		."<td>Money</td>";
		while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {	
			echo "<tr>";
			echo "<td><a href=\"cheatPlayerDetails.php?id=".$row['attacker_id']."\">".$row['username'] . "</a></td>";
			echo "<td>" . $row['attacks'] . "</td>";
			echo "<td>" . $row['money'] . "</td>";
			echo "</tr>";
		}
		echo "</table><br/><br/>";


		
	} catch(PDOException $ex) {
		echo "An Error occured!\n$ex";
	}
?>