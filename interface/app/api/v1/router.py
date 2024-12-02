from fastapi import APIRouter
# from app.api.v1.endpoints import auth, data, queue
from app.api.v1.endpoints import auth


api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
# api_router.include_router(data.router, prefix="/data", tags=["data"])
# api_router.include_router(queue.router, prefix="/queue", tags=["queue"])