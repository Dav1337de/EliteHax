<?php
include 'db.php';
include 'validate.php';
	try {
		if (!isset($_GET['code'])) { exit(""); }
		$input = $_GET['code'];
		//Base64 Decode
		$decoded = base64_decode($input);
		if ($decoded === false) { exit("INVALID CODE"); }
		//HMAC Retrieve
		$mac = mb_substr($decoded, 0, 32, '8bit'); // stored
		$message = mb_substr($decoded, 32, null, '8bit');
		//JSON Decode and Check
		$json = json_decode($message,true);
		$token = base64_decode($json["token"]);
		$email = base64_decode($json["email"]);
		$expires = $json["expires"];
		if (($token == null) or ($email == null) or ($expires==null)) { exit("INCOMPLETE CODE"); }
		//E-mail and Token Check
		$stmt = $db->prepare('SELECT * FROM password_reset WHERE email=? and reset_token=?');
		$stmt->bindValue(1, $email, PDO::PARAM_STR);
		$stmt->bindValue(2, $token, PDO::PARAM_STR);
		$stmt->execute();	
		if ($stmt->rowCount() == 0) { exit("TOKEN NOT FOUND"); }
		else {
			while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
				$username = $row["username"];
				$password = $row["password"];
				$email = $row["email"];
				$hmac_key = $row["hmac"];
			}
		}
		//HMAC Check
		$calc = hash_hmac('sha256', $message, $hmac_key, true); // calcuated
		if (!hash_equals($calc, $mac)) {
			exit("INVALID CHECKSUM");
		}
		//Expire Check
		$currTime = new DateTime('NOW');
		$expireTime = new DateTime($json["expires"]);
		if ($currTime > $expireTime) {
			exit("TOKEN EXPIRED");
		}
	} catch(PDOException $ex) {
		echo "An Error occured! $ex";
	}
?>
<!DOCTYPE html>
<html>
<head>
<title>EliteHax Change Password</title>
<script>
function validatePassword() {
var newPassword,confirmPassword,output = true;

newPassword = document.frmChange.newPassword;
confirmPassword = document.frmChange.confirmPassword;

if(!newPassword.value) {
newPassword.focus();
document.getElementById("newPassword").innerHTML = " Required!";
output = false;
}
else if(!confirmPassword.value) {
confirmPassword.focus();
document.getElementById("confirmPassword").innerHTML = " Required!";
output = false;
}
if(newPassword.value != confirmPassword.value) {
newPassword.value="";
confirmPassword.value="";
newPassword.focus();
document.getElementById("confirmPassword").innerHTML = " Passwords don't match!";
output = false;
} 	
return output;
}
</script>
</head>
<body>
<form name="frmChange" method="post" action="setNewPasswordAction.php?code=<?php echo urlencode($input);?>" onSubmit="return validatePassword()">
<div style="width:500px;">
<table border="0" cellpadding="10" cellspacing="0" width="500" align="center" class="tblSaveForm">
<tr class="tableheader">
<td colspan="2">EliteHax Change Password</td>
</tr>
<tr>
<td><label>New Password (Min:10, Max: 30)</label></td>
<td><input type="password" name="newPassword" class="txtField"/><span id="newPassword" class="required"></span></td>
</tr>
<td><label>Confirm Password</label></td>
<td><input type="password" name="confirmPassword" class="txtField"/><span id="confirmPassword" class="required"></span></td>
</tr>
<tr>
<td colspan="2"><input type="submit" name="submit" value="Submit" class="btnSubmit">
<input type="hidden" name="code" value="<?php echo urlencode($input);?>">
</td>
</tr>
</table>
</div>
</form>
</body></html>
