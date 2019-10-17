<?php
include "./connect.php";

$student_no = $_GET['student_no'];
$seat_no = $_GET['seat_no'];
$student_no=isset($_POST['student_no']) ? $_POST['student_no'] : '';
$seat_no = isset($_POST['seat_no']) ? $_POST['seat_no'] : '';

$sql="UPDATE seat SET student_no='$student_no', use_check = 2 WHERE seat_no='$seat_no'";
$result=mysqli_query($conn,$sql);
echo $result;
?>