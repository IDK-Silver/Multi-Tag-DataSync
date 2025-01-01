//預設重整頁面時會顯示根目錄資訊
document.addEventListener("DOMContentLoaded", function () {
    showRootDetails(); // 頁面加載時顯示 Root Folder 資訊
});

//根目錄info
const rootFolder = {
    filename: "/",              // 根目錄名稱
    type: "1",                  // 1 表示資料夾
    timestamp: "N/A",           // 預設時間戳
    uuid: rootFolderUUID, // Root Folder 的 UUID
    hash: "N/A"                 // 預設的 Hash 值
};

// 顯示檔案或資料夾詳細資訊
function showDetails(filename, type, timestamp, uuid, hash, element) {
    document.getElementById("filename").value = filename;
    document.getElementById("filename").setAttribute("title", filename);
    document.getElementById("timestamp").innerText = timestamp || "N/A";
    document.getElementById("uuid").innerText = uuid || "N/A";
    document.getElementById("hash").innerText = hash || "N/A";

    // 清空搜尋結果
    document.getElementById("search-results").innerHTML = "";

    if (uuid) {
        fetchTags(uuid); // 調用 fetchTags 函數來更新標籤顯示
    } else {
        document.getElementById("tags-list").innerHTML = "<li>No tags available.</li>";
    }

    // 若為資料夾，展開子項目
    if (type === "1") {
        fetchFolderContents(uuid, element);
    }
}

// 顯示根目錄詳細資訊
function showRootDetails() {
    showDetails(
        rootFolder.filename,    // 檔案名稱 "/"
        rootFolder.type,        // 類型，1 表示資料夾
        rootFolder.timestamp,   // 時間戳，預設為 "N/A"
        rootFolder.uuid,        // Root Folder 的 UUID
        rootFolder.hash,        // Hash，預設為 "N/A"
        null                    // 無需額外 element
    );
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
                <span class="material-icons" title="${item.filename || "Unnamed File"}">
                  ${item.d_id === "1" ? "folder" : "insert_drive_file"}
                </span>
                <span title="${item.filename || "Unnamed File"}">
                ${item.filename || "Unnamed File"}
                </span>`;

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

// 刪除檔案
function deleteFile() {
    const fileUUID = document.getElementById("uuid").innerText;

    if (!fileUUID || fileUUID === "N/A") {
        alert("請先選擇要刪除的檔案！");
        return;
    }

    if (!confirm("確定要刪除此檔案嗎？")) {
        return;
    }

    const requestData = {
        uuid: fileUUID,
    };

    fetch("http://127.0.0.1:8000/api/v1/file/info/modify", {
        method: "DELETE",
        headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + accessToken,
        },
        body: JSON.stringify(requestData),
    })
        .then((response) => {
            console.log("Response Status:", response.status);
            return response.json();
        })
        .then((data) => {
            console.log("Response Data:", data);
            if (data.detail === "File deleted Successfully.") {
                alert("檔案刪除成功！");
                location.reload(); // 重新載入頁面以更新檔案清單
            } else {
                alert("檔案刪除失敗：" + JSON.stringify(data));
            }
        })
        .catch((error) => {
            console.error("Error deleting file:", error);
            alert("發生錯誤，請稍後再試。");
        });
}

//檔案名稱tooltip
function applyTooltipForOverflow() {
    const elements = document.querySelectorAll(".sidebar li span");

    elements.forEach(el => {
        if (el.scrollWidth > el.clientWidth) {
            el.setAttribute("title", el.textContent); // 設置 Tooltip
        } else {
            el.removeAttribute("title"); // 移除無用的 Tooltip
        }
    });
}

//搜尋檔案
function searchFiles() {
    const query = document.getElementById("search-query").value.trim();

    if (!query) {
        alert("請輸入搜尋關鍵字！");
        return;
    }

    // 清空先前的搜尋結果
    const resultsContainer = document.getElementById("search-results");
    resultsContainer.innerHTML = "Loading...";

    // 構建 URL，將搜尋參數作為查詢字串
    const url = `http://127.0.0.1:8000/api/v1/file/info/search?filename=${encodeURIComponent(query)}`;

    // 調用 API 搜尋檔案
    fetch(url, {
        method: "GET",
        headers: {
            "Authorization": "Bearer " + accessToken
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            // 清空搜尋結果
            resultsContainer.innerHTML = "";

            if (!Array.isArray(data) || data.length === 0) {
                resultsContainer.innerHTML = "<li>No files found.</li>";
                return;
            }

            // 顯示搜尋結果
            data.forEach(item => {
                const li = document.createElement("li");
                li.innerHTML = `
                    <span class="material-icons" title="${item.filename}">
                        ${item.d_id === "1" ? "folder" : "insert_drive_file"}
                    </span>
                    <span title="${item.filename}">
                        ${item.filename}
                    </span>`;
                li.onclick = () =>
                    showDetails(
                        item.filename,
                        item.d_id,
                        item.timestamp,
                        item.uuid,
                        item.hash,
                        li
                    );
                resultsContainer.appendChild(li);
            });
        })
        .catch(error => {
            console.error("Error searching files:", error);
            resultsContainer.innerHTML = `<li>No files found.</li>`;
        });
}

// 獲取標籤並顯示
function fetchTags(uuid) {
    fetch(`http://127.0.0.1:8000/api/v1/file/tag/${uuid}`, {
        method: "GET",
        headers: {
            "Authorization": "Bearer " + accessToken
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(tags => {
            const tagsList = document.getElementById("tags-list");
            tagsList.innerHTML = ""; // 清空列表

            if (!tags || tags.length === 0) {
                const noTagItem = document.createElement("li");
                noTagItem.textContent = "No tags available.";
                tagsList.appendChild(noTagItem);
                return;
            }

            // 渲染標籤列表
            tags.forEach(tag => {
                const tagItem = document.createElement("li");
                tagItem.textContent = tag;
                tagItem.className = "tag-item"; // 可用於自定義樣式
                tagItem.onclick = () => deleteTag(uuid, tag); // 點擊刪除標籤
                tagsList.appendChild(tagItem);
            });
        })
        .catch(error => {
            console.error("Error fetching tags:", error);
            const tagsList = document.getElementById("tags-list");
            tagsList.innerHTML = "<li>Error loading tags</li>";
        });
}

// 新增標籤
function addTag() {
    const fileUUID = document.getElementById("uuid").innerText;
    const newTag = document.getElementById("new-tag").value.trim();

    if (!fileUUID || fileUUID === "N/A") {
        alert("請先選擇檔案！");
        return;
    }

    if (!newTag) {
        alert("請輸入標籤名稱！");
        return;
    }

    if (!/^[a-zA-Z0-9_ -]+$/.test(newTag)) {
        alert("標籤名稱包含不合法的字元！");
        return;
    }

    fetch("http://127.0.0.1:8000/api/v1/file/tag/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + accessToken
        },
        body: JSON.stringify({ uuid: fileUUID, tag: newTag })
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.detail === "Tag added") {
                alert("標籤新增成功！");
                fetchTags(fileUUID); // 更新標籤顯示
                document.getElementById("new-tag").value = ""; // 清空輸入框
            } else {
                alert("新增標籤失敗：" + JSON.stringify(data));
            }
        })
        .catch(error => {
            console.error("Error adding tag:", error);
            alert(`發生錯誤：${error.message}`);
        });
}

//刪除標籤
function deleteTag(fileUUID, tag) {
    if (!confirm(`確定要刪除標籤 "${tag}" 嗎？`)) {
        return;
    }

    fetch("http://127.0.0.1:8000/api/v1/file/tag/", {
        method: "DELETE",
        headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + accessToken
        },
        body: JSON.stringify({ uuid: fileUUID, tag: tag })
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            alert(`標籤 "${tag}" 已成功刪除！`);
            fetchTags(fileUUID); // 刪除成功後重新載入標籤
        })
        .catch(error => {
            console.error("Error deleting tag:", error);
            alert(`刪除標籤失敗：${error.message}`);
        });
}

// 下載檔案
function downloadFile() {
    const fileUUID = document.getElementById("uuid").innerText;
    const filename = document.getElementById("filename").value;

    if (!fileUUID || fileUUID === "N/A") {
        alert("請先選擇檔案！");
        return;
    }

    fetch(`http://127.0.0.1:8000/api/v1/file/require_queue/${fileUUID}`, {
        method: "GET",
        headers: {
            "Authorization": "Bearer " + accessToken,
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.status === "success" && data.content) {
                const binaryContent = atob(data.content); // 將 Base64 解碼為二進制內容
                const byteArray = new Uint8Array(binaryContent.length);

                for (let i = 0; i < binaryContent.length; i++) {
                    byteArray[i] = binaryContent.charCodeAt(i);
                }

                const blob = new Blob([byteArray], { type: "application/octet-stream" });
                const link = document.createElement("a");
                link.href = window.URL.createObjectURL(blob);
                link.download = filename || "downloaded_file"; // 預設檔案名稱
                link.click();
            } else {
                alert("無法下載檔案：" + data.detail || "未知錯誤");
            }
        })
        .catch(error => {
            console.error("Error downloading file:", error);
            alert("下載失敗，請稍後再試！");
        });
}
