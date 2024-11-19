<?php
session_start();

// 確認用戶已經登入
if (!isset($_SESSION['user_id'])) {
    die("請先登入後再使用編譯器功能。");
}

// 初始化變數
$output = "";
$code = ""; // 預設空的程式碼內容
$file_language = "python"; // 預設語言

// 處理文件上傳
if (isset($_FILES['fileToUpload'])) {
    $uploaded_file = $_FILES['fileToUpload']['tmp_name'];
    $file_name = $_FILES['fileToUpload']['name'];
    $file_language = pathinfo($file_name, PATHINFO_EXTENSION);

    // 根據文件擴展名設定語言
    if ($file_language == "py") $file_language = "python";
    elseif ($file_language == "cpp") $file_language = "cpp";
    elseif ($file_language == "java") $file_language = "java";

    // 讀取文件內容
    $code = file_get_contents($uploaded_file);
}

// 檢查是否有提交編譯請求
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['code'])) {
    // 取得用戶上傳的程式碼和語言
    $code = $_POST['code'];
    $language = $_POST['language'];
    $user_id = $_SESSION['user_id'];

    // 建立暫存文件名稱
    $file_name = "code." . ($language == "python" ? "py" : ($language == "cpp" ? "cpp" : "java"));
    $file_path = "/tmp/" . $file_name;
    file_put_contents($file_path, $code);

    // 根據語言選擇 Docker 命令
    $command = "";
    if ($language == "python") {
        $command = "docker run --rm -v /tmp:/app python:3.8 python /app/$file_name";
    } elseif ($language == "cpp") {
        $command = "docker run --rm -v /tmp:/app gcc:latest g++ /app/$file_name -o /app/a.out && docker run --rm -v /tmp:/app gcc:latest /app/a.out";
    } elseif ($language == "java") {
        $command = "docker run --rm -v /tmp:/app openjdk:latest javac /app/$file_name && docker run --rm -v /tmp:/app openjdk:latest java -cp /app " . pathinfo($file_name, PATHINFO_FILENAME);
    }

    // 執行命令並獲取輸出
    $output = shell_exec($command);

    // 將編譯結果存儲到資料庫
    $conn = new mysqli("localhost", "root", "", "multi-tag-datasync");
    $stmt = $conn->prepare("INSERT INTO compilations (user_id, filename, code, language, compile_status, output) VALUES (?, ?, ?, ?, ?, ?)");
    $compile_status = empty($output) ? "Error" : "Success";
    $stmt->bind_param("isssss", $user_id, $file_name, $code, $language, $compile_status, $output);
    $stmt->execute();
    $stmt->close();
    $conn->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>在線程式編譯器</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.63.1/codemirror.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.63.1/codemirror.min.js"></script>
</head>
<body>
    <h2>在線程式編譯器</h2>

    <!-- 文件上傳表單 -->
    <form action="compiler.php" method="post" enctype="multipart/form-data">
        <label for="fileToUpload">上傳程式文件：</label>
        <input type="file" name="fileToUpload" id="fileToUpload">
        <button type="submit">上傳並加載到編輯器</button>
    </form>

    <!-- 編輯器和執行表單 -->
    <form action="compiler.php" method="post">
        <label for="language">選擇語言：</label>
        <select name="language" id="language" onchange="updateEditorMode()">
            <option value="python" <?php if($file_language == "python") echo 'selected'; ?>>Python</option>
            <option value="cpp" <?php if($file_language == "cpp") echo 'selected'; ?>>C++</option>
            <option value="java" <?php if($file_language == "java") echo 'selected'; ?>>Java</option>
        </select>
        <textarea id="code" name="code"><?php echo htmlspecialchars($code); ?></textarea>
        <button type="submit">編譯與執行</button>
    </form>

    <h3>編譯結果</h3>
    <pre><?php echo htmlspecialchars($output); ?></pre>

    <script>
        // 初始化 CodeMirror 編輯器
        var editor = CodeMirror.fromTextArea(document.getElementById("code"), {
            lineNumbers: true,
            mode: "text/x-" + "<?php echo $file_language; ?>", // 根據上傳的文件自動設置模式
            theme: "default"
        });

        // 根據選擇的語言更新 CodeMirror 模式
        function updateEditorMode() {
            var language = document.getElementById("language").value;
            var mode = "text/x-python"; // 默認為 Python
            if (language === "cpp") mode = "text/x-c++src";
            else if (language === "java") mode = "text/x-java";
            editor.setOption("mode", mode);
        }
    </script>
</body>
</html>
