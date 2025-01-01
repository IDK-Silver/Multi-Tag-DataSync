<?php
// 開始 session，用來在登錄後保存用戶狀態
session_start();

$error_message = ''; // 用於存儲錯誤消息的變量

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['login'])) {
        // 獲取表單中的用戶名和密碼
        $user = $_POST['username'];
        $pass = $_POST['password'];

        // 準備要發送到 FastAPI 的表單數據
        $postData = http_build_query([
            'grant_type' => 'password',
            'username' => $user,
            'password' => $pass
        ]);

        // 初始化 cURL
        $ch = curl_init();

        // 設定 FastAPI 登錄端點 URL（根據您的實際情況修改）
        $url = "http://localhost:8000/api/v1/auth/login";

        // 設定 cURL 選項
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/x-www-form-urlencoded'
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
            // 登錄成功，設置 session
            $_SESSION['access_token'] = $responseData['access_token'];
            $_SESSION['token_type'] = $responseData['token_type'];

            $ch = curl_init();
            $me_url = "http://localhost:8000/api/v1/auth/me";
            curl_setopt($ch, CURLOPT_URL, $me_url);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: ' . $responseData['token_type'] . ' ' . $responseData['access_token']
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $me_response = curl_exec($ch);
            $me_http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

            if ($me_response === false) {
                die('cURL 錯誤 (me): ' . curl_error($ch));
            }

            curl_close($ch);

            $meData = json_decode($me_response, true);
           
            if ($me_http_code === 200 && isset($meData['username'])) {
                $_SESSION['logged_in'] = true;
                if (is_array($meData['username'])) {
                    // 从数组中提取用户名
                    $_SESSION['username'] = htmlspecialchars($meData['username']['username']);
                    $_SESSION['root_uuid'] = htmlspecialchars($meData['username']['root_uuid']);
                }
               
                // 跳轉到主要頁面
                header("Location: main.php");
                exit;
            } else {
                // 無法獲取用戶資訊
                $error_message = "無法獲取用戶資訊";
                // 如需調試，您可以取消註釋以下代碼
                // $error_message .= print_r($meData, true);
            }
        } else {
            // 登錄失敗，設置錯誤訊息
            if (isset($responseData['detail'])) {
                $error_message = htmlspecialchars($responseData['detail']);
            } else {
                $error_message = "未知錯誤";
                // 如需調試，您可以取消註釋以下代碼
                // $error_message .= print_r($responseData, true);
            }
            // 您可以取消註釋以下代碼以查看 HTTP 狀態碼
            // $error_message .= " HTTP 狀態碼: " . $http_code;
        }
    } elseif (isset($_POST['return'])) {
        // 處理返回按鈕
        header("Location: guest.php");
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="zh-TW">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style/login-style.css">
    <title>登錄</title>
    <script>
        <?php if (!empty($error_message)): ?>
            alert(<?php echo json_encode($error_message); ?>);
        <?php endif; ?>
    </script>
</head>

<body>
    <center>
        <h2>Multi-Tag-DataSync</h2>
        <form action="login.php" method="post">
            <label for="username">用戶名:</label>
            <input type="text" id="username" name="username"><br><br>
            <label for="password">密碼:</label>
            <input type="password" id="password" name="password"><br><br>
            <!-- 登錄按鈕 -->
            <input type="submit" name="login" value="確認">
            <!-- 返回按鈕 -->
            <input type="submit" name="return" value="返回">
        </form>
    </center>
</body>

</html>