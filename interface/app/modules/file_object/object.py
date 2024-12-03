import uuid
from datetime import datetime
from enum import IntEnum

from app.core import db
from app.core.db import DatabaseConnection
from typing import Union, List


class FileObjectType(IntEnum):
    file = 0
    directory = 1


class FileObjectUUID:
    def __init__(self, uuid=None):
        self.uuid:str = uuid

    def to_string(self) -> str:
        if self.uuid is None:
            return ''
        return self.uuid

    def __eq__(self, other):
        return self.to_string() == other.to_string()

    @staticmethod
    def generate():
        return FileObjectUUID(str(uuid.uuid4()))

class FileObject:
    def __init__(self):
        self.filename: str = ""
        self.uuid: FileObjectUUID = FileObjectUUID()
        self.parent_id: FileObjectUUID = FileObjectUUID()
        self.d_id: FileObjectType
        self.hash: str = ""
        self.timestamp: datetime

    def is_root(self) -> bool:
        return self.parent_id == self.uuid

    def __eq__(self, other):
        return self.uuid == other.uuid and self.hash == other.hash

    def __modify_by_dict__(self, dictionary):
        self.filename = dictionary["filename"]
        self.uuid = FileObjectUUID(dictionary["doc_uuid"])
        self.parent_id = FileObjectUUID(dictionary["parent_uuid"])
        self.d_id = FileObjectType(dictionary["d_id"])
        self.timestamp = dictionary["timestamp"]
        self.hash = dictionary["doc_hash"]

    @staticmethod
    def from_dict(dictionary):
        ret: FileObject = FileObject()
        ret.__modify_by_dict__(dictionary)
        return ret

    @staticmethod
    def from_db(doc_id: Union[str, FileObjectUUID]):
        ret = FileObject()
        db = DatabaseConnection.get_instance()

        if isinstance(doc_id, FileObjectUUID):
            doc_id = doc_id.to_string()

        doc_info = db.execute_query(
            "SELECT * FROM doc WHERE doc_uuid = %s",
            (doc_id,),
        )

        if len(doc_info) == 0:
            return None

        doc_info = doc_info[0]

        ret.__modify_by_dict__(doc_info)
        return ret

    @staticmethod
    def get_children(parent_doc_id: FileObjectUUID) -> list:
        db = DatabaseConnection.get_instance()

        children_info = db.execute_query(
            "SELECT * FROM doc WHERE parent_uuid = %s",
            (parent_doc_id,),
        )

        ret = []
        for children in children_info:
            file = FileObject()
            file.__modify_by_dict__(children)
            ret.append(file)

        return ret

    def __str__(self):
        ret = ''

        ret += 'filename : ' + self.filename              + '\t'
        ret += 'uuid : '     + self.uuid.to_string()      + '\t'
        ret += 'p_uuid : '   + self.parent_id.to_string() + '\n'

        return ret

    def is_valid(self):
        if self.filename is None:
            return False
        elif self.uuid is None:
            return False
        elif self.parent_id is None:
            return False
        elif self.d_id is None:
            return False
        elif self.hash is None:
            return False
        elif self.timestamp is None:
            return False

        return True





if __name__ == "__main__":
    doc = FileObject.from_db('00524c02-a740-11ef-95a9-0242ac150002')
    print(doc)
