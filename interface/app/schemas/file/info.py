from pydantic import BaseModel
from datetime import datetime
class DocUUIDSchema(BaseModel):
    uuid: str

class DocInfoSchema(BaseModel):
    filename: str
    uuid: str
    parent_id: str
    d_id: str
    hash: str
    timestamp: datetime

class UpdateDocInfoSchema(BaseModel):
    filename: str
    uuid: str
    parent_id: str
    d_id: int
    hash: str
