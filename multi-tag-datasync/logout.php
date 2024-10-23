<?php
session_start();
session_unset();
session_destroy();
header("Location: guest.php");
// 登出跳到guest.php畫面
exit;
?>
