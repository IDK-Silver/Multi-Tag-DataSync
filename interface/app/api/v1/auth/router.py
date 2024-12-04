import uuid
from datetime import timedelta, datetime
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from app.core.security import (
    verify_password,
    create_access_token,
    get_current_user,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    get_user_from_db,
    get_password_hash
)
from app.schemas.auth import Token, UserCreate, User
from app.core.db import DatabaseConnection
from app.modules.file_object.object import FileObjectType
router = APIRouter()


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # 驗證用戶
    user = get_user_from_db(form_data.username)

    if not user:
        raise HTTPException(status_code=401, detail="用戶名或密碼錯誤")
    
    if not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="用戶名或密碼錯誤")

    # 創建訪問令牌
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )
    token = Token(access_token=access_token, token_type="bearer")
    return token

@router.get("/me")
async def read_users_me(current_user: str = Depends(get_current_user)):
    return {"username": current_user}


@router.post("/register", response_model=Token)
async def register(user: UserCreate):
    db = DatabaseConnection.get_instance()

    # 檢查用戶名是否已存在
    existing_user = get_user_from_db(user.username)
    if existing_user:
        raise HTTPException(status_code=400, detail="用戶名已存在")

    root_uuid = uuid.uuid4()

    # 創建新用戶
    hashed_password = get_password_hash(user.password)
    db.execute_update(
        "INSERT INTO users (name, password_hash, root_uuid) VALUES (%s, %s, %s)",
        (user.username, hashed_password, root_uuid)
    )

    # create root doc
    user_id = get_user_from_db(user.username).user_id
    query = """
                INSERT INTO doc (filename, doc_uuid, parent_uuid, d_id, doc_hash, timestamp, uploaded_by)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
    params = (
        "/",
        root_uuid,
        root_uuid,
        int(FileObjectType.directory),
        "",
        datetime.now(),
        user_id
    )
    db.execute_update(query, params)

    # 創建訪問令牌
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )

    token = Token(access_token=access_token, token_type="bearer")

    return token
@router.post("/renew", response_model=Token)
def renew_token(user: User = Depends(get_current_user)):
    # 創建訪問令牌
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )
    token = Token(access_token=access_token, token_type="bearer")
    return token
