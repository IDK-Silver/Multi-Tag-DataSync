<?php

// Connecting to SQL
/*  @var mysqli  $conn */
require_once('./lib/php/db/connect_sql.php');


session_start();
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    // 如果未登錄，重定向到登錄頁面
    header("Location: login.php");
    exit;
}

// 取得現在登陸用戶名稱
$now_user = $_SESSION['name'];
$user_id = $_SESSION['user_id'];

// 設定當前檢視的資料夾，預設為根目錄
$current_folder_uuid = isset($_GET['folder_uuid']) ? $_GET['folder_uuid'] : null;
$current_folder_path = $now_user;

// 檢查是否存在預設資料夾，若無則創建
$default_folder_query = "SELECT * FROM doc WHERE uploaded_by = ? AND d_id = 1 AND filename = ?";
$stmt = $conn->prepare($default_folder_query);
$stmt->bind_param("is", $user_id, $now_user);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    // 創建預設資料夾
    $default_folder_path = "uploads/" . $now_user;
    mkdir($default_folder_path, 0777, true);
    $create_folder_query = "INSERT INTO doc (doc_uuid, parent_uuid, d_id, filename, doc_type, uploaded_by, file_path) VALUES (UUID(), NULL, 1, ?, 'folder', ?, ?)";
    $create_stmt = $conn->prepare($create_folder_query);
    $create_stmt->bind_param("sis", $now_user, $user_id, $default_folder_path);
    $create_stmt->execute();
    $create_stmt->close();
}
$default_folder = $result->fetch_assoc();
$folder_uuid = $default_folder['doc_uuid'];
$stmt->close();

//路徑顯示
if ($current_folder_uuid) {
    // 根據當前資料夾 UUID 獲取路徑
    $folder_query = "SELECT file_path, filename, parent_uuid FROM doc WHERE doc_uuid = ?";
    $stmt = $conn->prepare($folder_query);
    $stmt->bind_param("s", $current_folder_uuid);
    $stmt->execute();
    $stmt->bind_result($current_folder_path, $current_folder_name, $parent_folder_uuid);
    $stmt->fetch();
    $stmt->close();

    // 檢視資料夾完整的路徑
    $path_segments = [];
    $path_segments[] = $current_folder_name;
    $current_uuid = $parent_folder_uuid;

    while ($current_uuid) {
        $parent_query = "SELECT filename, parent_uuid FROM doc WHERE doc_uuid = ?";
        $stmt = $conn->prepare($parent_query);
        $stmt->bind_param("s", $current_uuid);
        $stmt->execute();
        $stmt->bind_result($parent_name, $current_uuid);
        $stmt->fetch();
        $stmt->close();

        if ($parent_name) {
            array_unshift($path_segments, $parent_name);
        }
    }
    $current_folder_path = implode('/', $path_segments);
} else {
    $current_folder_uuid = $folder_uuid;
    $parent_folder_uuid = null;
}

// 檢查是否有檔案被上傳
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    $current_folder_uuid = $_POST['current_folder'];
    $file = $_FILES['file'];

    // 檢查檔案上傳是否成功
    if ($file['error'] !== UPLOAD_ERR_OK) {
        die("File upload failed with error code " . $file['error']);
    }

    // 獲取當前資料夾名稱（根據 doc_uuid）
    $folder_query = "SELECT file_path FROM doc WHERE doc_uuid = ?";
    $stmt = $conn->prepare($folder_query);
    $stmt->bind_param("s", $current_folder_uuid);
    $stmt->execute();
    $stmt->bind_result($parent_folder_path);
    $stmt->fetch();
    $stmt->close();

    // 獲取檔案名稱並設置目標路徑
    $filename = basename($file['name']);
    $target_dir = $parent_folder_path; // 使用從資料庫中查找到的資料夾路徑
    $target_file = $target_dir . '/' . $filename;

    // 確保目標目錄存在
    if (!is_dir($target_dir)) {
        mkdir($target_dir, 0777, true);
    }

    // 將檔案移動到目標目錄
    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        // 檔案移動成功，將文件信息插入資料庫
        $insert_file_query = "INSERT INTO doc (doc_uuid, parent_uuid, d_id, filename, doc_type, uploaded_by, file_path) VALUES (UUID(), ?, 2, ?, ?, ?, ?)";
        $doc_type = pathinfo($filename, PATHINFO_EXTENSION); // 根據副檔名確定檔案類型
        $stmt = $conn->prepare($insert_file_query);
        $stmt->bind_param("sssis", $current_folder_uuid, $filename, $doc_type, $user_id, $target_file);

        if ($stmt->execute()) {
            echo "檔案上傳並成功儲存於資料庫中。";
        } else {
            echo "檔案已上傳，但儲存於資料庫時失敗。";
        }
        $stmt->close();
    } else {
        echo "檔案移動到目標目錄時失敗。";
    }
}

// 處理創建資料夾請求
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['folder_name'])) {
    $folder_name = $_POST['folder_name'];
    $parent_uuid = $_POST['parent_uuid'];

    // 設置新資料夾的路徑
    $parent_folder_query = "SELECT file_path FROM doc WHERE doc_uuid = ?";
    $stmt = $conn->prepare($parent_folder_query);
    $stmt->bind_param("s", $parent_uuid);
    $stmt->execute();
    $stmt->bind_result($parent_path);
    $stmt->fetch();
    $stmt->close();

    $new_folder_path = $parent_path . '/' . $folder_name;

    // 創建資料夾
    if (!is_dir($new_folder_path)) {
        mkdir($new_folder_path, 0777, true);
    }

    // 將資料夾信息插入資料庫
    $create_folder_query = "INSERT INTO doc (doc_uuid, parent_uuid, d_id, filename, doc_type, uploaded_by, file_path) VALUES (UUID(), ?, 1, ?, 'folder', ?, ?)";
    $stmt = $conn->prepare($create_folder_query);
    $stmt->bind_param("ssis", $parent_uuid, $folder_name, $user_id, $new_folder_path);

    if ($stmt->execute()) {
        echo "資料夾創建成功並儲存於資料庫中。";
    } else {
        echo "資料夾創建失敗。";
    }
    $stmt->close();
}

// 處理刪除檔案或資料夾請求
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_uuid'])) {
    $delete_uuid = $_POST['delete_uuid'];

    // 查找要刪除的檔案或資料夾
    $delete_query = "SELECT file_path, d_id FROM doc WHERE doc_uuid = ?";
    $stmt = $conn->prepare($delete_query);
    $stmt->bind_param("s", $delete_uuid);
    $stmt->execute();
    $stmt->bind_result($delete_path, $d_id);
    $stmt->fetch();
    $stmt->close();

    if ($d_id == 1) {
        // 如果是資料夾，遞歸刪除資料夾及其所有內容
        function deleteFolder($path)
        {
            if (is_dir($path)) {
                $files = array_diff(scandir($path), array('.', '..'));
                foreach ($files as $file) {
                    deleteFolder($path . '/' . $file);
                }
                rmdir($path);
            } elseif (is_file($path)) {
                unlink($path);
            }
        }
        deleteFolder($delete_path);
    } else {
        // 如果是檔案，直接刪除
        if (is_file($delete_path)) {
            unlink($delete_path);
        }
    }

    // 刪除資料庫中的對應記錄
    $delete_record_query = "DELETE FROM doc WHERE doc_uuid = ?";
    $stmt = $conn->prepare($delete_record_query);
    $stmt->bind_param("s", $delete_uuid);

    if ($stmt->execute()) {
        echo "檔案或資料夾刪除成功。";
    } else {
        echo "刪除過程中出現錯誤，請稍後再試。";
    }
    $stmt->close();
}

// 新增文件預覽邏輯
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['file_uuid'])) {
    $file_uuid = $_GET['file_uuid'];

    // 查找文件的詳細信息
    $file_query = "SELECT filename, file_path, doc_type FROM doc WHERE doc_uuid = ?";
    $stmt = $conn->prepare($file_query);
    $stmt->bind_param("s", $file_uuid);
    $stmt->execute();
    $stmt->bind_result($filename, $file_path, $doc_type);
    $stmt->fetch();
    $stmt->close();

    // 檢查文件是否存在
    if (file_exists($file_path)) {
        // 根據文件類型提供預覽
        header("Content-Type: " . mime_content_type($file_path));
        readfile($file_path);
        exit;
    } else {
        echo "文件未找到。";
    }
}
?>

<!DOCTYPE html>
<html lang="zh-TW">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Multi-Tag-DataSync Main Page</title>
    <link rel="stylesheet" href="style/main-style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
</head>

<body>
    <!-- 頁首 -->
    <header>
        <div class="header-content">
            <span>Multi-Tag-DataSync welcome <?php echo htmlspecialchars($now_user); ?>!</span>
            <button id="Button" onclick="handleUploadClick()">上傳檔案</button>
            <button id="Button" onclick="handleCreateFolderClick()">創建資料夾</button>
            <button id="Button" onclick="handleLogout()">登出</button>
            <input type="file" id="fileInput" style="display: none;" onchange="handleFileUpload(event)">
        </div>
    </header>

    <!-- 主容器 -->
    <div class="container">
        <!-- 左側樹狀結構 -->
        <div class="sidebar">
            <ul id="folderTree">
                <?php
                // 顯示根目錄
                echo '<li class="folder-item">
                        <span class="toggle-btn" onclick="toggleFolder(this)">+</span>
                        <span class="material-icons md-36">folder</span> <a href="?folder_uuid=' . $folder_uuid . '">' . htmlspecialchars($now_user) . '</a>
                        <ul class="tree-children" style="display: none;">';
                renderFolderTree($conn, $folder_uuid);
                echo '</ul></li>';

                function renderFolderTree($conn, $parent_uuid, $indent = 0)
                {
                    $query = "SELECT * FROM doc WHERE parent_uuid = ? AND d_id = 1";
                    $stmt = $conn->prepare($query);
                    $stmt->bind_param("s", $parent_uuid);
                    $stmt->execute();
                    $result = $stmt->get_result();

                    while ($folder = $result->fetch_assoc()) {
                        echo str_repeat("&nbsp;", $indent * 4) . '<li class="folder-item">
                            <span class="toggle-btn" onclick="toggleFolder(this)">+</span>
                            <span class="material-icons md-36">folder</span> <a href="?folder_uuid=' . $folder['doc_uuid'] . '">' . htmlspecialchars($folder['filename']) . '</a>
                            <ul class="tree-children" style="display: none;">';
                        renderFolderTree($conn, $folder['doc_uuid'], $indent + 1);
                        echo '</ul></li>';
                    }

                    $stmt->close();
                }
                ?>
            </ul>
        </div>

        <!-- 中間內容區 -->
        <div class="content">
            <div class="folder-header" id="folderHeader"><button id="gobake"
                    onclick="goBack()"><span class="material-icons md-36">arrow_back</span></button>正在檢視資料夾：<?php echo htmlspecialchars($current_folder_path); ?>
            </div>
            <div class="file-list" id="fileList">
                <?php
                // 從當前資料夾中獲取檔案列表並顯示
                $files_query = "SELECT * FROM doc WHERE parent_uuid = ?";
                $files_stmt = $conn->prepare($files_query);
                $files_stmt->bind_param("s", $current_folder_uuid);
                $files_stmt->execute();
                $files_result = $files_stmt->get_result();
                while ($file = $files_result->fetch_assoc()) {
                    $is_folder = $file['d_id'] == 1;
                    $file_link = $is_folder ? '?folder_uuid=' . $file['doc_uuid'] : '#';
                    echo '<div class="file-item" oncontextmenu="handleContextMenu(event, \'' . $file['doc_uuid'] . '\')">
                           <img></img>
                            <a href="' . $file_link . '">' . htmlspecialchars($file['filename']) . '</a>
                          </div>';
                }

                $files_stmt->close();
                ?>
            </div>
        </div>
    </div>
    <?php
    $conn->close();
    ?>
    <script>
        // 處理登出按鈕點擊
        function handleLogout() {
            window.location.href = 'logout.php';
        }

        // 處理上傳按鈕點擊
        function handleUploadClick() {
            document.getElementById('fileInput').click();
        }

        // 處理檔案上傳
        function handleFileUpload(event) {
            const file = event.target.files[0];
            if (file) {
                const formData = new FormData();
                formData.append('file', file);
                formData.append('user_id', <?php echo json_encode($user_id); ?>);
                formData.append('current_folder', <?php echo json_encode($current_folder_uuid); ?>);

                fetch('', {
                    method: 'POST',
                    body: formData
                }).then(response => response.text())
                    .then(result => {
                        alert(result);
                        // 可以刷新頁面或者重新加載文件列表
                        window.location.reload();
                    }).catch(error => {
                        console.error('Error:', error);
                        alert('上傳失敗，請稍後再試。');
                    });
            }
        }

        // 處理創建資料夾按鈕點擊
        function handleCreateFolderClick() {
            const folderName = prompt('請輸入新資料夾名稱:');
            if (folderName) {
                const formData = new FormData();
                formData.append('folder_name', folderName);
                formData.append('user_id', <?php echo json_encode($user_id); ?>);
                formData.append('parent_uuid', <?php echo json_encode($current_folder_uuid); ?>);

                fetch('', {
                    method: 'POST',
                    body: formData
                }).then(response => response.text())
                    .then(result => {
                        alert(result);
                        // 可以刷新頁面或者重新加載資料夾列表
                        window.location.reload();
                    }).catch(error => {
                        console.error('Error:', error);
                        alert('創建資料夾失敗，請稍後再試。');
                    });
            }
        }

        // 處理返回上層資料夾按鈕點擊
        function goBack() {
            const parentUuid = <?php echo json_encode($parent_folder_uuid); ?>;
            if (parentUuid) {
                window.location.href = '?folder_uuid=' + parentUuid;
            } else {
                window.location.href = '';
            }
        }

        // 處理右鍵選單
        function handleContextMenu(event, fileUuid) {
            event.preventDefault();
            // 建立右鍵選單
            const menu = document.createElement('div');
            menu.className = 'context-menu';
            menu.style.top = `${event.clientY}px`;
            menu.style.left = `${event.clientX}px`;

            // 添加預覽選項
            const previewOption = document.createElement('div');
            previewOption.textContent = '預覽';
            previewOption.onclick = () => {
                window.open('main.php?file_uuid=' + fileUuid, '_blank');
                document.body.removeChild(menu);
            };
            menu.appendChild(previewOption);

            // 添加刪除選項
            const deleteOption = document.createElement('div');
            deleteOption.textContent = '刪除';
            deleteOption.onclick = () => {
                handleDelete(fileUuid);
                document.body.removeChild(menu);
            };
            menu.appendChild(deleteOption);

            document.body.appendChild(menu);

            // 點擊其他地方時移除右鍵選單
            document.addEventListener('click', () => {
                if (menu.parentElement) {
                    menu.parentElement.removeChild(menu);
                }
            }, { once: true });
        }

        // 處理刪除檔案或資料夾按鈕點擊
        function handleDelete(deleteUuid) {
            if (confirm('確定要刪除這個項目嗎？')) {
                const formData = new FormData();
                formData.append('delete_uuid', deleteUuid);

                fetch('', {
                    method: 'POST',
                    body: formData
                }).then(response => response.text())
                    .then(result => {
                        alert(result);
                        // 可以刷新頁面或者重新加載資料夾列表
                        window.location.reload();
                    }).catch(error => {
                        console.error('Error:', error);
                        alert('刪除失敗，請稍後再試。');
                    });
            }
        }

        // 處理展開和收起按鈕點擊
        function toggleFolder(toggleBtn) {
            const treeChildren = toggleBtn.parentElement.querySelector('.tree-children');
            if (treeChildren.style.display === 'none') {
                treeChildren.style.display = 'block';
                toggleBtn.textContent = '-';
            } else {
                treeChildren.style.display = 'none';
                toggleBtn.textContent = '+';
            }
        }
    </script>
</body>

</html>