<?php
    // 檢查是否按下了 "登陸" 或 "註冊" 按鈕
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // 檢查是否按下了 "登陸" 按鈕
        if (isset($_POST['login'])) {
            // 跳轉到 login.php
            header("Location: login.php");
            exit; // 確保之後的代碼不會被執行
        }

        // 檢查是否按下了 "註冊" 按鈕
        if (isset($_POST['sign'])) {
            // 跳轉到 sign_up.php
            header("Location: sign_up.php");
            exit; // 確保之後的代碼不會被執行
        }
    }
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <!-- 引入外部的 CSS 文件 -->
    <link rel="stylesheet" href="guest-style.css">
</head>
<body>
    <div class="container">
        <h1>Multi-Tag-Datasync Repository</h1>

        <!-- 表單提交處理 -->
        <form method="POST" action="guest.php">
            <!-- 登陸按鈕 -->
            <input type="submit" name="login" value="登陸" id="login">
            <!-- 註冊按鈕 -->
            <input type="submit" name="sign" value="註冊" id="sign">
        </form> 

        <!-- 圖片部分，設置寬度和高度 -->
        <img src="image0.png" alt="Image">
    </div>
</body>
</html>
