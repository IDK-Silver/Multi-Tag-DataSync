from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from app.core.security import get_current_user
from app.schemas.auth import User
from app.schemas.file.info import  DocUUIDSchema, DocInfoSchema, UpdateDocInfoSchema
from app.modules.file_object.object import FileObject
from app.core.db import DatabaseConnection

router = APIRouter()

@router.post("/", response_model=DocInfoSchema)
async def get_file_info(doc_info: DocUUIDSchema, current_user: User = Depends(get_current_user)):
    # check uuid is not empty
    if len(doc_info.uuid) == 0:
        raise HTTPException(
            status_code=404,
            detail="File uuid is required.",
        )

    file = FileObject.from_db(doc_info.uuid)

    if file is None:
        raise HTTPException(
            status_code=404,
            detail="File notfound.",
        )

    if not file.is_valid():
        raise HTTPException(
            status_code=404,
            detail="File is not valid.",
        )

    info = DocInfoSchema(
        filename=file.filename,
        uuid=file.uuid.to_string(),
        parent_id=file.parent_id.to_string(),
        d_id=file.d_id,
        hash=file.hash,
        timestamp=file.timestamp
    )

    return info

@router.post("/modify")
async def update_file_info(doc_info: UpdateDocInfoSchema, current_user: User = Depends(get_current_user)):

    db = DatabaseConnection.get_instance()

    remote_doc = FileObject.from_db(doc_info.uuid)

    if remote_doc is None:
        query = """
            INSERT INTO doc (filename, doc_uuid, parent_uuid, d_id, doc_hash, timestamp, uploaded_by)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
        params = (
            doc_info.filename,
            doc_info.uuid,
            doc_info.parent_id,
            doc_info.d_id,
            doc_info.hash,
            datetime.now(),
            current_user.user_id
        )
        db.execute_update(query, params)
        return HTTPException(
            status_code=200,
            detail="Inset new file info",
        )
    else:
        db = DatabaseConnection.get_instance()
        query = """
            UPDATE doc
            SET filename = %s, doc_uuid = %s, parent_uuid = %s, d_id = %s, doc_hash = %s, timestamp = %s, uploaded_by = %s
            WHERE doc_uuid = %s
            """
        params = (
            doc_info.filename,
            doc_info.uuid,
            doc_info.parent_id,
            doc_info.d_id,
            doc_info.hash,
            datetime.now(),
            current_user.user_id,
            doc_info.uuid
        )
        db.execute_update(query, params)
        return HTTPException(
            status_code=200,
            detail="Update file info",
        )

@router.delete("/modify")
async def delete_file_info(doc_info: DocUUIDSchema, current_user: User = Depends(get_current_user)):
    db = DatabaseConnection.get_instance()
    remote_doc = FileObject.from_db(doc_info.uuid)
    if remote_doc is None:
        raise HTTPException(
            status_code=404,
            detail="File notfound.",
        )

    db.execute_update(
        "DELETE FROM doc WHERE doc_uuid = %s",
        (doc_info.uuid, )
    )

    return HTTPException(
        status_code=200,
        detail="File deleted Successfully.",
    )


