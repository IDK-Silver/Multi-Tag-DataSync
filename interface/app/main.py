from fastapi import FastAPI
from app.api.v1.router import api_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Your API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 允許所有來源，或指定前端域名 ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],  # 允許所有 HTTP 方法，例如 ["POST", "GET", "OPTIONS"]
    allow_headers=["*"],  # 允許所有標頭
)

app.include_router(api_router, prefix="/api/v1") 