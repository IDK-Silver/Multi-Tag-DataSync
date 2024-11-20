<?php
// 開始 session，用來在登錄後保存用戶狀態
session_start();

// 檢查表單是否提交
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['login'])) {
        // 這裡是處理登錄的邏輯

        // Connecting to SQL
        /*  @var mysqli  $conn */
        require_once('./lib/php/db/connect_sql.php');

        // 取得表單中的用戶名和密碼
        $user = $_POST['username'];
        $pass = $_POST['password'];

        // 檢查用戶名和密碼是否匹配
        $sql = "SELECT * FROM users WHERE name = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $user);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            // 驗證密碼（與存儲的加密密碼進行比較）
            if (hash('sha256', $pass) === $row['password_hash']) {
                // 登錄成功，設置 session
                $_SESSION['logged_in'] = true;
                $_SESSION['user_id'] = $row['user_id'];
                $_SESSION['name'] = $row['name'];

                // 跳轉到主要的頁面
                header("Location: main.php");
                exit;
            } else {
                echo "<span style='color: red;'>密碼錯誤</span>";
            }
        } else {
            echo "<span style='color: red;'>用戶名不存在</span>";
        }

        // 關閉連接
        $stmt->close();
        $conn->close();
    } elseif (isset($_POST['return'])) {
        // 如果按下的是註冊按鈕，跳轉到註冊頁面
        header("Location: guest.php");
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>login</title>
</head>
<body>
    <center>
    <h2>登錄</h2>
    <form action="login.php" method="post">
        <label for="username">用戶名:</label>
        <input type="text" id="username" name="username"><br><br>
        <label for="password">密碼:</label>
        <input type="password" id="password" name="password"><br><br>
        <!-- 登錄按鈕 -->
        <input type="submit" name="login" value="確認">
        <!-- 註冊按鈕 -->
        <input type="submit" name="return" value="返回">
    </form>
    </center>
</body>
</html>
