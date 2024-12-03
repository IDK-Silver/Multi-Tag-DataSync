from typing import Optional
from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserLogin(BaseModel):
    username: str
    password: str

class User(BaseModel):
    user_id: int
    username: str
    hashed_password: str
    root_uuid: str

class UserCreate(BaseModel):
    username: str
    password: str