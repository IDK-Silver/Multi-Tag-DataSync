from anyio.streams import file
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from app.modules.file_object import file_object_queue
from app.schemas.auth import User
from app.core.security import get_current_user
from app.modules.file_object.object import FileObject, FileObjectUUID, FileObjectType
import os
import pathlib
import typing
from app.schemas.file.info import DocInfoSchema, DocUUIDSchema
import configparser


router = APIRouter()


config = configparser.ConfigParser()
config.read('config/required_queue_config.ini')
storage_path = pathlib.Path(config['RequiredQueue']['storage_path'])
os.makedirs(storage_path.absolute(), exist_ok=True)
split_word:str = config['RequiredQueue']['split_word']

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


@router.post("/{uuid}")
async def add_binary_to_queue(uuid:str, file: UploadFile = File(...),  current_user: User = Depends(get_current_user)):
    """
    Add a binary file to the server file.
    - Upload a file to server, and remove it from the queue.
    """
    # try:
        # Create a FileObject by upload file
    upload_file_obj = FileObject()
    upload_file_obj.filename = uuid
    upload_file_obj.uuid = uuid

    if  upload_file_obj in file_object_queue:

        # save file
        try :
            file_path = os.path.join(storage_path, uuid)

            # Read the file content
            content = await file.read()

            # Write the content to a file
            with open(file_path, "wb") as f:
                f.write(content)
        except OSError as e:
            raise HTTPException(status_code=400, detail=str(e))

        file_object_queue.remove(upload_file_obj)

        return {"status": "success", "detail": f"File {file.filename} remove from the require queue."}

    else:
        return HTTPException(status_code=400, detail=f"Upload file is not in required queue")


@router.get("/{uuid}")
async def get_binary_from_queue(uuid: str, current_user: User = Depends(get_current_user)):
    """
    Retrieve a binary file from the require queue by UUID.
    - Returns the file content as binary if found.
    """
    # Search for the file in the queue

    exist_uuids = [
        file for file in os.listdir(storage_path)
    ]

    if uuid not in exist_uuids:
        file_object_queue.append(FileObject(uuid))
        raise HTTPException(status_code=404, detail="File not found in the queue.")
    try:
        # Assume file is stored locally (for demonstration purposes)
        with open(storage_path.joinpath(uuid), "rb") as f:
            binary_content = f.read()
        return {"status": "success", "filename": uuid, "content": binary_content.hex()}
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="File not found on the server.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading file: {str(e)}")
