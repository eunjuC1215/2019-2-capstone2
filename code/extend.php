<?php
include "./connect.php";

$student_no = $_GET['student_no'];
$student_no=isset($_POST['student_no']) ? $_POST['student_no'] : '';

$get_time = "SELECT end_time FROM seat WHERE student_no='$student_no'";
$get_row = mysqli_query($conn, $get_time);
$time = mysqli_fetch_array($get_row);

$sql = "UPDATE seat SET end_time=DATE_ADD('$time[0]', INTERVAL 1 HOUR)  WHERE student_no='$student_no'";
$result = mysqli_query($conn, $sql);


if($result == 1){
	echo "Success";
}else{
	echo "Fail";
}
?>