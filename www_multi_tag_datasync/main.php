<?php
session_start();

// 檢查用戶是否已登錄
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    // 如果未登錄，重定向到登錄頁面
    header("Location: login.php");
    exit;
}
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "www_multi_tag_datasync";
$conn = new mysqli($servername, $username, $password, $dbname);

// 取得用戶名稱
$username = $_SESSION['username'];
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>主頁</title>
</head>

<body>
    <center>
    <h1>歡迎, <?php echo htmlspecialchars($username); ?>!</h1>
    <p>這是你的主頁。</p>
    <a href="logout.php">登出</a>
    <form action="upload.php" method="post" enctype="multipart/form-data">
        <input type="file" name="fileToUpload" id="fileToUpload">
        <input type="submit" value="上傳文件" name="submit">
    </form>

    </center>
</body>

</html>
