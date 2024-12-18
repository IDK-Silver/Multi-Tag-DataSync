<!-- main.php -->
<?php
// Initialize session and error reporting
session_start();
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Check if the user is logged in
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

// Get the logged-in user info
$now_user = $_SESSION['username'];
$rootID = $_SESSION['root_uuid'];
$access_token = $_SESSION['access_token'];
$current_folder_uuid = isset($_GET['folder_uuid']) ? $_GET['folder_uuid'] : null;

// API Base URL
$api_base_url = "http://127.0.0.1:8000";

// Get folder contents from the API
function get_folder_contents($folder_uuid, $access_token)
{
    global $api_base_url;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $api_base_url . "/api/v1/file/info/children");
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $access_token
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $postData = json_encode(['uuid' => $folder_uuid]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if ($http_code !== 200) {
        echo "API Error: HTTP $http_code - Response: $response";
        curl_close($ch);
        return [];
    }

    curl_close($ch);
    return json_decode($response, true);
}
function get_file_info($file_uuid, $access_token)
{
    global $api_base_url;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $api_base_url . "/api/v1/file/info/");
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $access_token
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $postData = json_encode(['uuid' => $file_uuid]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if ($http_code !== 200) {
        echo "API Error: HTTP $http_code - Response: $response";
        curl_close($ch);
        return null;
    }

    curl_close($ch);
    return json_decode($response, true);
}

// Fetch folder contents
$folder_contents = get_folder_contents($rootID, $access_token);
$file_infos = [];

if ($folder_contents) {
    foreach ($folder_contents as $item) {
        if (isset($item['uuid'])) {
            $file_infos[] = get_file_info($item['uuid'], $access_token);
        }
    }
}
?>

<!DOCTYPE html>
<html lang="zh-TW">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Files</title>
    <link rel="stylesheet" href="style/main-style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    
</head>

<body>
    <div class="container">
        <!-- 左側目錄 -->
        <aside class="sidebar">
            <ul id="file-tree">
                <li onclick="fetchFolderContents('<?php echo $rootID; ?>', this); showRootDetails();">
                    <span class="material-icons">folder</span>
                    /
                </li>
            </ul>
            <!-- 新增登出按鈕 -->
            <button class="logout-button" onclick="location.href='logout.php'">Logout</button>
        </aside>

        <!-- 右側詳細資訊 -->
        <main class="details-panel">
            <div class="details-content">
                <div class="details-header">
                    <h3>檔案資訊</h3>
                    <!-- 新增標籤功能 -->
                    <div class="tag-section">
                        <input type="text" id="new-tag" placeholder="新增標籤" />
                        <button onclick="addTag()">新增</button>
                        <button id="delete-file-button" onclick="deleteFile()">刪除檔案</button>
                    </div>
                </div>

                <label for="filename">Filename</label>
                <input type="text" id="filename" readonly>

                <label for="timestamp">Timestamp</label>
                <p id="timestamp"></p>

                <label for="uuid">UUID</label>
                <p id="uuid"></p>

                <label for="hash">Hash</label>
                <p id="hash">N/A</p>

            </div>
        </main>
    </div>

    <script>
        // 傳遞 PHP 變數到 JavaScript
        const rootFolderUUID = "<?php echo $rootID; ?>";
        const accessToken = "<?php echo $access_token; ?>";
    </script>
    <script src="main.js"></script>
    


</body>

</html>