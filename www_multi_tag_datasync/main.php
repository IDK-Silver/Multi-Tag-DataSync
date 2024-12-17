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
                <li onclick="fetchFolderContents('<?php echo $rootID; ?>', this)">
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
        const accessToken = "<?php echo $access_token; ?>";

        // 顯示檔案或資料夾詳細資訊
        function showDetails(filename, type, timestamp, uuid, hash, element) {
            document.getElementById("filename").value = filename;
            document.getElementById("timestamp").innerText = timestamp || "N/A";
            document.getElementById("uuid").innerText = uuid || "N/A";
            document.getElementById("hash").innerText = hash || "N/A";

            // 若為資料夾，展開子項目
            if (type === "1") {
                fetchFolderContents(uuid, element);
            }
        }

        // 獲取子資料夾內容
        function fetchFolderContents(folderUuid, parentElement) {
            // 檢查是否已經展開，若已展開則收合
            let existingUl = parentElement.querySelector("ul");
            if (existingUl) {
                existingUl.remove();
                return;
            }

            // 創建一個新的 <ul>
            const ul = document.createElement("ul");
            const loadingItem = document.createElement("li");
            loadingItem.textContent = "Loading...";
            loadingItem.className = "loading";
            ul.appendChild(loadingItem);
            parentElement.appendChild(ul);

            // 第一步：調用 getChildren API 獲取 UUID 陣列
            fetch("http://127.0.0.1:8000/api/v1/file/info/children", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer " + accessToken
                },
                body: JSON.stringify({ uuid: folderUuid })
            })
                .then(response => response.json())
                .then(uuidArray => {
                    // 清空 "Loading..." 提示
                    ul.innerHTML = "";

                    if (!uuidArray || uuidArray.length === 0) {
                        ul.innerHTML = "<li>No files found</li>";
                        return;
                    }

                    // 第二步：根據每個 UUID 調用 getFileInfo API，獲取詳細資訊
                    const fileInfoPromises = uuidArray.map(uuidObj =>
                        fetch("http://127.0.0.1:8000/api/v1/file/info/", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                                "Authorization": "Bearer " + accessToken
                            },
                            body: JSON.stringify({ uuid: uuidObj.uuid }) // 獲取詳細資訊
                        }).then(response => response.json())
                    );

                    // 等待所有 getFileInfo API 請求完成
                    return Promise.all(fileInfoPromises);
                })
                .then(fileInfos => {
                    // 渲染每個文件或資料夾
                    fileInfos.forEach(item => {
                        const li = document.createElement("li");
                        li.innerHTML = `
                    <span class="material-icons">${item.d_id === "1" ? "folder" : "insert_drive_file"}</span>
                    ${item.filename || "Unnamed File"}
                `;

                        li.onclick = () =>
                            showDetails(
                                item.filename || "Unnamed File",
                                item.d_id,
                                item.timestamp,
                                item.uuid,
                                item.hash,
                                li
                            );

                        // 如果是資料夾，支援展開功能
                        if (item.d_id === "folder") {
                            li.addEventListener("click", (e) => {
                                e.stopPropagation(); // 阻止事件冒泡
                                fetchFolderContents(item.uuid, li);
                            });
                        }
                        li.onclick = (e) => {
                            e.stopPropagation(); // 防止事件冒泡
                            showDetails(
                                item.filename || "Unnamed File",
                                item.d_id,
                                item.timestamp,
                                item.uuid,
                                item.hash,
                                li
                            );
                        };

                        ul.appendChild(li);
                    });
                })
                .catch(error => {
                    console.error("Error fetching folder contents:", error);
                    ul.innerHTML = '<li>No files</li>';
                });
        }

    </script>
</body>

</html>