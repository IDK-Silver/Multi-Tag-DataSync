import os
import base64
from fastapi import APIRouter, HTTPException, Request
from app.modules.file_object import file_object_queue, FileObject

router = APIRouter()

@router.post("/check-file/{uuid}")
async def check_file(uuid: str):
    """
    接收 UUID，檢查檔案是否存在。
    - 如果檔案存在，回傳 base64 編碼的檔案內容。
    - 如果檔案不存在，將 file_info 加入 require queue，並回傳 404。
    """
    # 從資料庫獲取檔案資訊
    file = FileObject.from_db(uuid)
    if not file:
        raise HTTPException(status_code=404, detail="File not found in database")

    if file.filename in os.listdir("."):  # 假設當前工作目錄為檔案根目錄
        # 讀取檔案並轉換為 Base64
        try:
            with open(file.filename, "rb") as f:
                binary_content = f.read()
            encoded_content = base64.b64encode(binary_content).decode("utf-8")
            return {"status": "success", "binary_file": encoded_content}
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error reading file: {str(e)}")
    else:
        # 檔案不存在，加入待處理佇列
        if file not in file_object_queue:
            file_object_queue.append(file)
        raise HTTPException(status_code=404, detail="File not found and added to require queue")