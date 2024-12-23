<?php
// 開始 session
session_start();

$error_message = ''; // 用於存儲錯誤消息的變量

// 檢查是否提交表單
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 從表單取得用戶名和密碼，並使用 trim() 去掉空格
    $user = trim($_POST['username']);
    $pass = trim($_POST['password']);
    $confirm_pass = trim($_POST['confirm_password']);

    // 檢查是否按下了 "返回" 按鈕
    if (isset($_POST['return'])) {
        header("Location: guest.php");
        exit;
    }

    // 檢查用戶名和密碼是否為空，或密碼是否一致
    if (empty($user) || empty($pass)) {
        $error_message = "用戶名和密碼不得為空。";
    } elseif ($pass !== $confirm_pass) {
        $error_message = "密碼不一致，請重新輸入。";
    } else {
        // 準備要發送到 FastAPI 的數據
        $postData = json_encode([
            'username' => $user,
            'password' => $pass
        ]);

        // 初始化 cURL
        $ch = curl_init();

        // 設定 FastAPI 註冊端點 URL（根據您的實際情況修改）
        $url = "http://localhost:8000/api/v1/auth/register";

        // 設定 cURL 選項
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // 執行 cURL 請求
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        // 檢查 cURL 錯誤
        if ($response === false) {
            die('cURL 錯誤: ' . curl_error($ch));
        }

        // 關閉 cURL
        curl_close($ch);

        // 解碼 FastAPI 的 JSON 響應
        $responseData = json_decode($response, true);

        // 處理響應
        if ($http_code === 200 && isset($responseData['access_token'])) {
            // 註冊成功，跳轉到登錄頁面
            echo "<script>
                    alert('註冊成功！即將跳轉到登錄頁面...');
                    setTimeout(function() {
                        window.location.href = 'login.php';
                    }, 1000);
                  </script>";
            exit;
        } else {
            // 註冊失敗，設置錯誤訊息
            if (isset($responseData['detail'])) {
                $error_message = htmlspecialchars($responseData['detail']);
            } else {
                $error_message = "註冊過程中出現錯誤，請稍後再試。";
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="zh-TW">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style/sign_up-style.css">
    <title>註冊</title>
    <script>
        <?php if (!empty($error_message)) : ?>
            alert(<?php echo json_encode($error_message); ?>);
        <?php endif; ?>
    </script>
</head>

<body>
    <center>
    <h2>Multi-Tag-DataSync</h2>
    <form action="sign_up.php" method="post">
        <label for="username">用戶名:</label>
        <input type="text" id="username" name="username"><br><br>
        <label for="password">密碼:</label>
        <input type="password" id="password" name="password"><br><br>
        <label for="confirm_password">確認密碼:</label>
        <input type="password" id="confirm_password" name="confirm_password"><br><br>
        <input type="submit" name="register" value="確認">
        <input type="submit" name="return" value="返回">
    </form>
    </center>
</body>

</html>
