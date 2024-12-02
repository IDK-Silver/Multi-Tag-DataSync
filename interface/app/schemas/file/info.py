from pydantic import BaseModel

class DocUUIDSchema(BaseModel):
    uuid: str

class DocInfoSchema(BaseModel):
    filename: str
    uuid: str
    parent_id: str
    d_id: str
    hash: str
    timestamp: str
