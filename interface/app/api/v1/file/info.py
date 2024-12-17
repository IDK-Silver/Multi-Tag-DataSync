from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.core.security import get_current_user
from app.schemas.auth import User
from app.schemas.file.info import DocUUIDSchema, DocInfoSchema, UpdateDocInfoSchema
from app.modules.file_object.object import FileObject
from app.core.db import DatabaseConnection
import typing
router = APIRouter()

@router.post("/", response_model=DocInfoSchema)
async def get_file_info(doc_info: DocUUIDSchema, current_user: User = Depends(get_current_user)):
    """
    Retrieve file information by its UUID.
    - If the UUID is empty or invalid, return a 404 error.
    - If the file is invalid or not found, return a 404 error.
    - Otherwise, return the file's details in a structured format.
    """
    # Ensure the UUID is not empty
    if len(doc_info.uuid) == 0:
        raise HTTPException(
            status_code=404,
            detail="File uuid is required.",
        )

    # Fetch file information from the database
    file = FileObject.from_db(doc_info.uuid)

    if file is None:
        raise HTTPException(
            status_code=404,
            detail="File notfound.",
        )

    # Validate the retrieved file object
    if not file.is_valid():
        raise HTTPException(
            status_code=404,
            detail="File is not valid.",
        )

    # Prepare and return the response
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
    """
    Update or insert file information in the database.
    - If the file does not exist, insert a new record.
    - If the file exists, update its information.
    """
    db = DatabaseConnection.get_instance()

    # Check if the file already exists in the database
    remote_doc = FileObject.from_db(doc_info.uuid)

    if remote_doc is None:
        # Insert new file info into the database
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
        # Update existing file info
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
    """
    Delete a file from the database by its UUID.
    - If the file is not found, return a 404 error.
    - If the file is a root file, prevent deletion and return a 404 error.
    - Otherwise, delete the file successfully.
    """
    db = DatabaseConnection.get_instance()
    remote_doc = FileObject.from_db(doc_info.uuid)

    if remote_doc is None:
        return HTTPException(
            status_code=404,
            detail="File notfound.",
        )

    # Prevent deletion of root files
    if remote_doc.is_root():
        return HTTPException(
            status_code=404,
            detail="Can't delete root file.",
        )

    # Execute deletion query
    db.execute_update(
        "DELETE FROM doc WHERE doc_uuid = %s",
        (doc_info.uuid, )
    )

    return HTTPException(
        status_code=200,
        detail="File deleted Successfully.",
    )

@router.post("/add_tags")
async def add_tags(doc_info: DocUUIDSchema, tags: List[str], current_user: User = Depends(get_current_user)):
    """
    Add tags to a file.
    - If the file does not exist, return a 404 error.
    - Otherwise, add the specified tags to the file.
    """
    db = DatabaseConnection.get_instance()

    # Check if the file exists
    query = "SELECT * FROM doc WHERE doc_uuid = %s"
    result = db.execute_query(query, (doc_info.uuid,))
    if not result:
        raise HTTPException(status_code=404, detail="File not found")

    # Add tags to the file
    for tag in tags:
        insert_query = """
            INSERT INTO file_tags (doc_uuid, tag)
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE tag = tag
        """
        db.execute_update(insert_query, (doc_info.uuid, tag))

    return HTTPException(
        status_code=200,
        detail="Tag add Successfully.",
    )

@router.delete("/delete_tags")
async def delete_tags(doc_info: DocUUIDSchema, tags: List[str], current_user: User = Depends(get_current_user)):
    """
    Delete tags from a file.
    - Remove the specified tags associated with the file's UUID.
    """
    db = DatabaseConnection.get_instance()

    # Delete tags from the file
    for tag in tags:
        delete_query = "DELETE FROM file_tags WHERE doc_uuid = %s AND tag = %s"
        db.execute_update(delete_query, (doc_info.uuid, tag))

    return HTTPException(
        status_code=200,
        detail="Tag delete Successfully.",
    )

@router.get("/filter_by_tags")
async def filter_files_by_tags(tags: List[str], current_user: User = Depends(get_current_user)):
    """
    Filter files by tags.
    - Retrieve file UUIDs that match all specified tags.
    """
    db = DatabaseConnection.get_instance()

    # Query files matching all tags
    query = """
        SELECT doc_uuid
        FROM file_tags
        WHERE tag IN (%s)
        GROUP BY doc_uuid
        HAVING COUNT(DISTINCT tag) = %s
    """
    formatted_tags = ", ".join(["%s"] * len(tags))
    result = db.execute_query(query % (formatted_tags, len(tags)), tuple(tags))

    # Return matched file UUIDs
    file_uuids = [row["doc_uuid"] for row in result]
    return HTTPException(
        status_code=200,
        detail="Filter files Successfully.",
    )



@router.post("/children", response_model=typing.List[DocUUIDSchema])
async def get_children(doc_info: DocUUIDSchema, current_user: User = Depends(get_current_user)):

    db = DatabaseConnection.get_instance()

    children_infos = db.execute_query(
        "SELECT doc_uuid FROM doc WHERE parent_uuid = %s AND parent_uuid != doc.doc_uuid" ,
        (doc_info.uuid,),
    )

    ret = [DocUUIDSchema(uuid=info['doc_uuid']) for info in children_infos]

    return ret