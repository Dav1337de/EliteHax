local myData = require("mydata")

local upgradeTable = {
	internet = { name="Internet", type="internet", img="img/internet.png"},
	siem = { name="SIEM", type="siem", img="img/siem.png"},
	firewall = { name="Firewall", type="firewall", img="img/firewall.png"},
	ips = { name="IPS", type="ips", img="img/ips.png"},
	c2c = { name="C2C", type="c2c", img="img/c2c-server.png"},
	anon = { name="Anonymizer", type="anon", img="img/anon.png"},
	webs = { name="Web Server", type="webs", img="img/web-server.png"},
	apps = { name="Application Server", type="apps", img="img/application-server.png"},
	dbs = { name="Database Server", type="dbs", img="img/db-server.png"},	
	cpu = { name="CPU", type="cpu", img="img/cpu.png"},
	ram = { name="RAM", type="ram", img="img/ram.png"},
	hdd = { name="Hard Disk", type="hdd", img="img/hdd.png"},
	gpu = { name="GPU", type="gpu", img="img/gpu.png"},
	fan = { name="Cooling", type="fan", img="img/fan.png"},
	av = { name="Antivirus", type="av", img="img/antivirus.png"},
	malware = { name="Malware", type="malware", img="img/malware.png"},
	exploit = { name="Exploit", type="exploit", img="img/exploit.png"},
	scan = { name="Scanner", type="scan", img="img/scan.png"},
	cryptominer = { name="Cryptominer", type="cryptominer", img="img/cryptominer.png"},
}

return upgradeTable