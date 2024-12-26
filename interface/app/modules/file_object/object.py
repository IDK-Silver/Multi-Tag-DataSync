import uuid
from datetime import datetime
from enum import IntEnum
from typing import Union, List

from app.core import db
from app.core.db import DatabaseConnection
import typing 


class FileObjectType(IntEnum):
    """檔案類型：檔案或目錄"""
    file = 0
    directory = 1


class FileObjectUUID:
    """檔案的 UUID 表示，帶有相關操作"""
    def __init__(self, uuid=None):
        self.uuid: str = uuid

    def to_string(self) -> str:
        """返回 UUID 的字串形式"""
        if self.uuid is None:
            return ''
        return self.uuid

    def __eq__(self, other):
        """判斷兩個 UUID 是否相等"""
        if isinstance(other, FileObjectUUID):
            return self.to_string() == other.to_string()
        else:
            return self.to_string() == other

    @staticmethod
    def generate():
        """生成一個新的 UUID"""
        return FileObjectUUID(str(uuid.uuid4()))


class FileObject:
    """表示一個檔案或目錄的對象"""
    def __init__(self, uuid:FileObjectUUID =FileObjectUUID()):
        self.filename: str = ""  # 檔案名稱
        self.uuid: FileObjectUUID = uuid
        if isinstance(self.uuid, str):
            self.uuid = FileObjectUUID(uuid=uuid)
        self.parent_id: FileObjectUUID = FileObjectUUID()  # 父目錄的 UUID
        self.d_id: FileObjectType = FileObjectType.file  # 檔案類型 (file 或 directory)
        self.hash: str = ""  # 檔案的 hash 值
        self.timestamp: datetime = datetime.now()  # 檔案的創建時間

    def is_root(self) -> bool:
        """檢查是否為根目錄"""
        return self.parent_id == self.uuid

    def __eq__(self, other):
        """判斷兩個 FileObject 是否相等"""
        return self.uuid == other.uuid and self.hash == other.hash

    def __modify_by_dict__(self, dictionary):
        """用資料庫查詢結果字典更新對象的屬性"""
        self.hash = dictionary["doc_hash"]
        self.filename = dictionary["filename"]
        self.uuid = FileObjectUUID(dictionary["doc_uuid"])
        self.parent_id = FileObjectUUID(dictionary["parent_uuid"])
        self.d_id = FileObjectType(dictionary["d_id"])
        self.timestamp: datetime = dictionary["timestamp"]
        self.timestamp = dictionary["timestamp"]

    @staticmethod
    def from_dict(dictionary):
        """從字典生成 FileObject"""
        ret: FileObject = FileObject()
        ret.__modify_by_dict__(dictionary)
        return ret


    @staticmethod
    def from_db(doc_id: Union[str, FileObjectUUID]):
        """
        從資料庫中獲取檔案對象
        :param doc_id: 檔案的 UUID
        :return: FileObject 或 None
        """

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
        """獲取指定父目錄下的所有子對象"""

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
        """返回對象的字串表示，用於打印"""

        ret = ''

        ret += 'filename : ' + self.filename              + '\t'
        ret += 'uuid : '     + self.uuid.to_string()      + '\t'
        ret += 'p_uuid : '   + self.parent_id.to_string() + '\n'

        return ret

    def is_valid(self):
        """檢查 FileObject 是否所有屬性有效"""
        if not all([
            self.filename,
            self.uuid,
            self.parent_id,
            self.d_id is not None,
            # Do not valid that
            # self.hash,
            self.timestamp
        ]):
            return False
        return True


class Node:
    """紅黑樹節點"""
    def __init__(self, file_obj: FileObject, color="red"):
        self.file_obj = file_obj  # 節點存儲的 FileObject
        self.color = color        # 節點顏色 ("red" 或 "black")
        self.left = None          # 左子節點
        self.right = None         # 右子節點
        self.parent = None        # 父節點


class FileObjectTree:
    """檔案對象的紅黑樹，用於高效管理檔案結構"""
    def __init__(self):
        self.TNULL = Node(None, color="black")  # 表示空節點的特殊節點
        self.root = self.TNULL  # 初始化樹的根節點

    def insert(self, file_obj: FileObject):
        """
        插入新的檔案對象到紅黑樹
        :param file_obj: 要插入的 FileObject
        """
        if not file_obj.is_valid():
            raise ValueError(f"Invalid FileObject: {file_obj}")

        new_node = Node(file_obj)
        new_node.left = self.TNULL
        new_node.right = self.TNULL

        parent = None
        current = self.root
        while current != self.TNULL:
            parent = current
            if new_node.file_obj.timestamp < current.file_obj.timestamp:
                current = current.left
            else:
                current = current.right

        new_node.parent = parent
        if parent is None:
            self.root = new_node
        elif new_node.file_obj.timestamp < parent.file_obj.timestamp:
            parent.left = new_node
        else:
            parent.right = new_node

        new_node.color = "red"  # 新插入的節點設為紅色
        self.fix_insert(new_node)

    def fix_insert(self, node):
        """修正插入操作後的紅黑樹性質"""
        while node.parent and node.parent.color == "red":
            if node.parent == node.parent.parent.left:
                uncle = node.parent.parent.right
                if uncle.color == "red":
                    # Case 1: 叔叔節點是紅色
                    uncle.color = "black"
                    node.parent.color = "black"
                    node.parent.parent.color = "red"
                    node = node.parent.parent
                else:
                    if node == node.parent.right:
                        # Case 2: 節點是右孩子
                        node = node.parent
                        self.left_rotate(node)
                    # Case 3: 節點是左孩子
                    node.parent.color = "black"
                    node.parent.parent.color = "red"
                    self.right_rotate(node.parent.parent)
            else:
                uncle = node.parent.parent.left
                if uncle.color == "red":
                    # Case 1: 叔叔節點是紅色
                    uncle.color = "black"
                    node.parent.color = "black"
                    node.parent.parent.color = "red"
                    node = node.parent.parent
                else:
                    if node == node.parent.left:
                        # Case 2: 節點是左孩子
                        node = node.parent
                        self.right_rotate(node)
                    # Case 3: 節點是右孩子
                    node.parent.color = "black"
                    node.parent.parent.color = "red"
                    self.left_rotate(node.parent.parent)
        self.root.color = "black"

    def left_rotate(self, x):
        """執行左旋操作"""
        if x.right == self.TNULL:
            raise RuntimeError("Cannot perform left rotation: right child is TNULL")
        y = x.right
        x.right = y.left
        if y.left != self.TNULL:
            y.left.parent = x
        y.parent = x.parent
        if x.parent is None:
            self.root = y
        elif x == x.parent.left:
            x.parent.left = y
        else:
            x.parent.right = y
        y.left = x
        x.parent = y

    def right_rotate(self, x):
        """執行右旋操作"""
        if x.left == self.TNULL:
            raise RuntimeError("Cannot perform right rotation: left child is TNULL")
        y = x.left
        x.left = y.right
        if y.right != self.TNULL:
            y.right.parent = x
        y.parent = x.parent
        if x.parent is None:
            self.root = y
        elif x == x.parent.right:
            x.parent.right = y
        else:
            x.parent.left = y
        y.right = x
        x.parent = y

    def print_tree(self):
        """以中序遍歷的方式列印紅黑樹結構"""
        def inorder_traversal(node):
            if node != self.TNULL:
                inorder_traversal(node.left)
                if node.file_obj:
                    print(node.file_obj)
                inorder_traversal(node.right)

        if self.root == self.TNULL:
            print("Tree is empty")
        else:
            inorder_traversal(self.root)

file_object_queue: typing.List[FileObject] = [
    
]

if __name__ == "__main__":
    doc = FileObject.from_db('00524c02-a740-11ef-95a9-0242ac150002')
    print(doc)
