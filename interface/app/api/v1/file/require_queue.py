from anyio.streams import file
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from app.modules.file_object import file_object_queue
from app.schemas.auth import User
from app.core.security import get_current_user
from app.modules.file_object.object import FileObject, FileObjectUUID, FileObjectType
from datetime import datetime
import typing
from app.schemas.file.info import DocInfoSchema
router = APIRouter()


@router.get("/", response_model=typing.List[DocInfoSchema])
async def list_queue(current_user: User = Depends(get_current_user)):
    """
    List all files currently in the require queue.
    - Returns a list of file objects in the queue.
    """
    ret_list: typing.List[DocInfoSchema] = [
        DocInfoSchema(
            filename=file.filename,
            uuid=file.uuid.to_string(),
            parent_id=file.parent_id.to_string(),
            d_id=file.d_id,
            hash=file.hash,
            timestamp=file.timestamp
        ) for file in file_object_queue
    ]

    return ret_list


@router.post("/")
async def add_binary_to_queue(file: UploadFile = File(...), current_user: User = Depends(get_current_user)):
    """
    Add a binary file to the require queue.
    - Upload a file to add it to the queue.
    """
    try:
        # Create a new FileObject
        file_obj = FileObject()
        file_obj.filename = file.filename
        file_obj.uuid = FileObjectUUID.generate()  # Generate a unique UUID
        file_obj.parent_id = FileObjectUUID("root")  # Default parent ID
        file_obj.d_id = FileObjectType.file  # Default type as file
        file_obj.timestamp = datetime.now()
        file_obj.hash = "binary_hash_placeholder"  # Placeholder for hash

        # Append to the queue
        file_object_queue.append(file_obj)

        return {"status": "success", "detail": f"File {file.filename} added to the require queue."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error adding file to queue: {str(e)}")


@router.get("/{uuid}")
async def get_binary_from_queue(uuid: str, current_user: User = Depends(get_current_user)):
    """
    Retrieve a binary file from the require queue by UUID.
    - Returns the file content as binary if found.
    """
    # Search for the file in the queue
    file_obj = next((file for file in file_object_queue if file.uuid.to_string() == uuid), None)

    if not file_obj:
        file_object_queue.append(FileObject(uuid))
        raise HTTPException(status_code=404, detail="File not found in the queue.")


    try:
        # Assume file is stored locally (for demonstration purposes)
        with open(file_obj.filename, "rb") as f:
            binary_content = f.read()
        return {"status": "success", "filename": file_obj.filename, "content": binary_content.hex()}
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="File not found on the server.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading file: {str(e)}")
