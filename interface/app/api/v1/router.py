from fastapi import APIRouter
# from app.api.v1.auth import auth, data, queue
from app.api.v1.auth import router as auth_router
from app.api.v1.file import router as file_router


api_router = APIRouter()

api_router.include_router(auth_router.router, prefix="/auth", tags=["auth"])
api_router.include_router(file_router.router, prefix="/file", tags=["file"])
