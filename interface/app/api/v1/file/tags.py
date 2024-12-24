from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.core.security import get_current_user
from app.schemas.auth import User
from app.schemas.file.tag import DocTagSchema
from app.modules.file_object.object import FileObject
from app.core.db import DatabaseConnection
import typing
router = APIRouter()

@router.post("/")
async def add_tag_to_db(tag_info: DocTagSchema  ,current_user: User = Depends(get_current_user)):

    # ensure input info is valid
    if tag_info.uuid is None and tag_info.tag is None:
        return HTTPException(
            status_code=404,
            detail="No tag or doc-uuid was provided"
        )

    # ensure file info is exists in database
    doc_info = FileObject.from_db(tag_info.uuid)
    if doc_info.uuid is None:
        return HTTPException(
            status_code=404,
            detail="Not found document by uuid"
        )

    # create db connect
    db= DatabaseConnection.get_instance()


    # ensure tag is exists
    query = """
        SELECT tag FROM tags WHERE builder_id = %s AND tag = %s;
    """
    result = db.execute_query(query, (current_user.user_id, tag_info.tag))

    # if tag is not exist, create it
    if result is None or len(result) == 0:
        query = """
            INSERT INTO tags (builder_id, tag) VALUES (%s, %s);
        """
        db.execute_update(query, (current_user.user_id, tag_info.tag))

    # search file tag where is in database or not
    query = """
        SELECT doc_uuid, tag FROM doc_tags WHERE doc_uuid = %s AND tag = %s;
    """

    result = db.execute_query(query, (tag_info.uuid, tag_info.tag))

    # insert new tag info into database
    if result is None or len(result) == 0:
        print(tag_info)
        query = """
           INSERT INTO doc_tags (doc_uuid, tag)
           VALUES (%s, %s)
       """
        db.execute_update(query, (tag_info.uuid, tag_info.tag, ))

        return HTTPException(
            status_code=200,
            detail="Tag added"
        )
    # upload new info into database
    else:
        return HTTPException(
            status_code=200,
            detail="Tag already exists"
        )

@router.get("/{uuid}")
async def get_tag_by_doc_uuid(uuid: str  ,current_user: User = Depends(get_current_user)):
    # # ensure input info is valid
    if uuid is None:
        return HTTPException(
            status_code=404,
            detail="No doc-uuid was provided"
        )
    # ensure file info is exists in database
    doc_info = FileObject.from_db(uuid)
    if doc_info.uuid is None:
        return HTTPException(
            status_code=404,
            detail="Not found document by uuid"
        )

    # create db connect
    db = DatabaseConnection.get_instance()

    query = """
        SELECT tag FROM doc_tags WHERE doc_uuid = %s;
    """

    return [info['tag'] for info in db.execute_query(query, (uuid,)) ]


@router.delete("/")
async def delete_tag_from_db(tag_info: DocTagSchema, current_user: User = Depends(get_current_user)):
    """
    刪除文件的特定標籤
    """
    # 確保輸入的資料有效
    if not tag_info.uuid or not tag_info.tag:
        raise HTTPException(
            status_code=400,
            detail="Both doc-uuid and tag must be provided"
        )

    # 確保文件存在於資料庫中
    doc_info = FileObject.from_db(tag_info.uuid)
    if not doc_info or doc_info.uuid is None:
        raise HTTPException(
            status_code=404,
            detail="Document not found by the provided UUID"
        )

    # 建立資料庫連線
    db = DatabaseConnection.get_instance()

    # 查詢標籤是否存在於文件的標籤中
    query = """
        SELECT * FROM doc_tags WHERE doc_uuid = %s AND tag = %s;
    """
    result = db.execute_query(query, (tag_info.uuid, tag_info.tag))
    if not result or len(result) == 0:
        raise HTTPException(
            status_code=404,
            detail="Tag not found for the provided document UUID"
        )

    # 刪除標籤
    query = """
        DELETE FROM doc_tags WHERE doc_uuid = %s AND tag = %s;
    """
    db.execute_update(query, (tag_info.uuid, tag_info.tag))

    return {"detail": f"Tag '{tag_info.tag}' deleted successfully from document '{tag_info.uuid}'"}
