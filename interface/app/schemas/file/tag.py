from pydantic import BaseModel
from datetime import datetime

class DocTagSchema(BaseModel):
    uuid: str
    tag: str
