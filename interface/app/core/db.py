import os
import pymysql
from pymysql.cursors import DictCursor
from dbutils.pooled_db import PooledDB
import configparser
from dotenv import load_dotenv


class DatabaseConnection:
    _instance = None
    _pool = None

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def __init__(self):
        if DatabaseConnection._instance is not None:
            raise Exception("This class is a singleton!")
        else:
            DatabaseConnection._instance = self
            self._initialize_connection_pool()

    def _initialize_connection_pool(self):
        # Load environment variables from .env file
        load_dotenv()

        # Load configuration from config file
        config = configparser.ConfigParser()
        config.read('config/db_config.ini')

        # Prioritize environment variables, fall back to config file
        db_config = {
            'host': os.getenv('DB_HOST') or config.get('Database', 'host'),
            'user': os.getenv('DB_USER') or config.get('Database', 'user'),
            'password': os.getenv('DB_PASSWORD') or config.get('Database', 'password'),
            'database': os.getenv('DB_NAME') or config.get('Database', 'database'),
            'port': int(os.getenv('DB_PORT') or config.get('Database', 'port')),
            'charset': 'utf8mb4',
            'cursorclass': DictCursor
        }

        self._pool = PooledDB(
            creator=pymysql,
            maxconnections=6,
            mincached=2,
            maxcached=5,
            blocking=True,
            **db_config
        )

    def get_connection(self):
        return self._pool.connection()

    def execute_query(self, query, params=None):
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params or ())
                return cursor.fetchall()

    def execute_update(self, query, params=None):
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                affected_rows = cursor.execute(query, params or ())
                conn.commit()
                return affected_rows


# Usage example
if __name__ == "__main__":
    db = DatabaseConnection.get_instance()

    results = db.execute_query("SELECT * FROM users WHERE user_id = %s", (1, ))
    print(results)

    # # Example query
    # results = db.execute_query("SELECT * FROM users WHERE user_id = %s", (1,))
    # for row in results:
    #     print(row)
    #
    # # Example update
    # affected = db.execute_update("UPDATE users SET name = %s WHERE id = %s", ("New Name", 1))
    # print(f"Affected rows: {affected}")