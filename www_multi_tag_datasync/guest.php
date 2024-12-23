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

    <link rel="stylesheet" href="style\guest-style.css">
</head>

<body>
    <div class="container">
        <h1>Multi-Tag-Datasync Repository</h1>
        <form method="POST" action="guest.php">
            <input type="submit" name="login" value="登陸" id="login">
            <input type="submit" name="sign" value="註冊" id="sign">
        </form>

        <img src="https://i0.wp.com/www.printmag.com/wp-content/uploads/2021/02/4cbe8d_f1ed2800a49649848102c68fc5a66e53mv2.gif?resize=476%2C280&ssl=1" alt="Image">
    </div>
</body>

</html>