from fastapi import APIRouter
from app.api.v1.file import bin, info, require_queue

router = APIRouter()

router.include_router(bin.router, prefix="/bin")
router.include_router(info.router, prefix="/info")
router.include_router(require_queue.router, prefix="/require_queue")
