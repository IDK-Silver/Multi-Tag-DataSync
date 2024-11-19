<?php
// 開始 session
session_start();

// 檢查是否提交表單
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 連接資料庫
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "www_multi_tag_datasync";

    // 建立資料庫連接
    $conn = new mysqli($servername, $username, $password, $dbname);

    // 檢查連接是否成功
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // 從表單取得用戶名和密碼
    $user = trim($_POST['username']);  // 使用 trim() 去掉空格
    $pass = trim($_POST['password']);
    $confirm_pass = trim($_POST['confirm_password']);

    // 檢查是否按下了 "返回" 按鈕
    if (isset($_POST['return'])) {
        header("Location: guest.php");
        exit;
    }

    // 檢查用戶名和密碼是否為空
    if (empty($user) || empty($pass)) {
        echo "用戶名和密碼不得為空。";
    } elseif ($pass !== $confirm_pass) {
        echo "密碼不一致，請重新輸入。";
    } else {
        // 檢查用戶名是否已存在
        $sql = "SELECT * FROM users WHERE name = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $user);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // 用戶名已存在
            echo "用戶名已被註冊，請選擇其他用戶名。";
        } else {
            // 插入新用戶到資料庫
            // 將密碼加密處理
            $hashed_password = hash('sha256', $pass);

            // 插入新用戶記錄
            $insert_sql = "INSERT INTO users (name, password_hash) VALUES (?, ?)";
            $insert_stmt = $conn->prepare($insert_sql);
            $insert_stmt->bind_param("ss", $user, $hashed_password);

            if ($insert_stmt->execute()) {
                // 註冊成功，跳轉到登錄頁面
                echo "<script>
                        alert('註冊成功！即將跳轉到登錄頁面...');
                        setTimeout(function() {
                            window.location.href = 'login.php';
                        }, 5);
                      </script>";
            } else {
                echo "註冊過程中出現錯誤，請稍後再試。";
            }
        }

        // 關閉連接
        $stmt->close();
        $insert_stmt->close();
        $conn->close();
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>sign up</title>
</head>

<body>
    <center>
    <h2>註冊</h2>
    <form action="sign_up.php" method="post">
        <label for="username">用戶名:</label>
        <input type="text" id="username" name="username"><br><br>
        <label for="password">密碼:</label>
        <input type="password" id="password" name="password"><br><br>
        <label for="confirm_password">確認密碼:</label>
        <input type="password" id="confirm_password" name="confirm_password"><br><br>
        <input type="submit" name="login" value="確認">
        <input type="submit" name="return" value="返回">
    </form>
    </center>
</body>

</html>