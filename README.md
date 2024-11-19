

# Multi-Tag-DataSync

- 建議VSCODE php server套件 教學:https://youtu.be/Mct8Xw_BK8s?si=5texzYu8hGWTFlUy

## Usage

先把www_multi_tag_datasync.sql引入到本地的資料庫中，創建基本的table屬性.
如果php server set好了後先到VSCODE中開啟guest.php並右鍵選擇PHP server:serve project理論上瀏覽器會跳出你的guest.php頁面，
接下來建議先去註冊一個user，理論上引入sql是沒有data的，理論上我測過上傳跟刪除的邏輯沒有問題，也就是資料庫也會連鎖更新每個table的tuple，
因為部分外來鑑我使用casade delete來連鎖刪除，不同使用者的檔案也會區隔開，目前預覽好像只能作用在pdf上，以上有問題dc跟我說 :)

![{CFBF26DB-8568-4669-8504-C037701C1E0E}](https://github.com/user-attachments/assets/18ce866e-e492-4ec8-82c7-711dd43e8cd5)

## Function
- 創建資料夾
- 上傳檔案
- 對檔案或資料夾右鍵會跳出預覽或是刪除的功能
- 主畫面中 正在檢視資料夾： 會顯示目前資料夾的路徑
- 左邊side bar會顯示資料夾的層狀關係

## Wait to fix
- 檔案的預覽圖
- alert視窗會跳出整串html code
- 版面的美化
- 預覽形式的優化
## UML圖
![image](https://github.com/user-attachments/assets/bdc12f02-ea55-4d92-a4be-bf786fd371f8)

