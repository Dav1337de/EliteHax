<?php
	//OK
	$resp = "{\"status\": \"OK\"}";

	//Update Suggested
	//$resp = "{\"status\": \"US\"}";

	//Update Required
	//$resp = "{\"status\": \"UR\"}";

	//Custom Message - Continue
	//$resp = "{\"status\": \"CM\",\n\"message\": \"Custom Message!\",\n\"login\": \"Y\"}";

	//Custom Message - Force Close
	//$resp = "{\"status\": \"CM\",\n\"message\": \"Custom Message!\",\n\"login\": \"N\"}";

	//echo $resp;
	echo base64_encode($resp);
?>