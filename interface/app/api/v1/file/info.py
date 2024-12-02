from fastapi import APIRouter, Depends, HTTPException
from app.core.security import get_current_user
from app.schemas.auth import User
from app.schemas.file.info import  DocUUIDSchema, DocInfoSchema
from app.models.file_object.object import FileObject

router = APIRouter()

@router.post("/", response_model=DocInfoSchema)
async def get_file_info(doc_info: DocUUIDSchema, current_user: User = Depends(get_current_user)):
    # check uuid is not empty
    if len(doc_info.uuid) == 0:
        raise HTTPException(
            status_code=404,
            detail="File uuid is required.",
        )

    file = FileObject.get_from_db(doc_info.uuid)

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