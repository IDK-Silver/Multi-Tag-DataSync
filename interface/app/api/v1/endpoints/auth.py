from datetime import timedelta
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
from app.schemas.auth import Token, UserCreate
from app.core.db import DatabaseConnection

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

    # 創建新用戶
    hashed_password = get_password_hash(user.password)
    db.execute_update(
        "INSERT INTO users (name, password_hash) VALUES (%s, %s)",
        (user.username, hashed_password)
    )

    # 創建訪問令牌
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )

    token = Token(access_token=access_token, token_type="bearer")

    return token