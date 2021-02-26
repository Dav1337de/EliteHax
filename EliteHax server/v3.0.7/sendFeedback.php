<?php
	include 'db.php';
	include 'validate.php';
	
	if ((!isset($_POST['f'])) or (!isset($_POST['q'])) or (!isset($_POST['a'])))
		exit("An Error occured!");
	else {
		$question=$_POST['q'];
		$answer=$_POST['a'];
		$feedback=base64_decode($_POST['f']);
	}
	if ((($question!=1) and ($question!=2)) or (($answer!="y") and ($answer!="n"))) { exit("An Error occured!"); }
	else {
		if ($question==1) { 
			$answert="answer1"; 
			$feedbackt="feedback1";
			$timestampt="timestamp1";
		}
		elseif ($question==2) { 
			$answert="answer2"; 
			$feedbackt="feedback2";
			$timestampt="timestamp2";
		}
		if ($answer=="y") {
			$answer=2;
		}
		elseif ($answer=="n") {
			$answer=1;
		}
	}
		
	try {
		$id = getIdFromToken($db);
		
		$stmt = $db->prepare("UPDATE feedback SET {$answert}=?,{$feedbackt}=?,{$timestampt}=NOW() WHERE user_id=?");
		$stmt->bindValue(1, $answer, PDO::PARAM_INT);
		$stmt->bindValue(2, $feedback, PDO::PARAM_STR);
		$stmt->bindValue(3, $id, PDO::PARAM_INT);
		$stmt->execute();
		$resp = "{\n\"status\": \"OK\"}";
		
		//echo $resp;
		echo base64_encode($resp);		

	} catch(PDOException $ex) {
		echo "An Error occured!\n";
	}
?>