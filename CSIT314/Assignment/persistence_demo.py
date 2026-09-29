"""Python version of the class diagram: domain model + persistence layer.
Uses sqlite3 so it runs anywhere; swap the driver for MySQL in real use."""
import sqlite3
from abc import ABC, abstractmethod
from dataclasses import dataclass, field, fields
from datetime import datetime
from enum import Enum
from typing import Generic, Optional, TypeVar

# ---------- Enums (<<enumeration>> Role, Status) ----------
class Role(Enum):
    CUSTOMER = "CUSTOMER"
    ID = "ID"
    ADMIN = "ADMIN"

class Status(Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"

# ---------- Domain model ----------
@dataclass
class BaseEntity(ABC):                      # abstract mapped superclass
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)

@dataclass
class User(BaseEntity):                     # abstract in the diagram
    email: str = ""
    password_hash: str = ""
    role: Role = Role.CUSTOMER
    first_name: str = ""
    last_name: str = ""
    phone: Optional[str] = None
    status: Status = Status.ACTIVE
    user_id: Optional[int] = None

    def get_full_name(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()

@dataclass
class Customer(User):                       # inheritance: Customer -> User
    role: Role = Role.CUSTOMER

@dataclass
class InteriorDesigner(User):
    role: Role = Role.ID

@dataclass
class Admin(User):
    role: Role = Role.ADMIN

# Single-table inheritance: the role column decides which subclass to build
ROLE_TO_CLASS = {Role.CUSTOMER: Customer, Role.ID: InteriorDesigner, Role.ADMIN: Admin}

# ---------- Persistence layer ----------
T = TypeVar("T")

class ConnectionManager:                    # <<singleton>>
    _instance = None

    def __new__(cls, db_path=":memory:"):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.conn = sqlite3.connect(db_path)
            cls._instance.conn.row_factory = sqlite3.Row
        return cls._instance

    def commit(self):   self.conn.commit()
    def rollback(self): self.conn.rollback()

class Repository(ABC, Generic[T]):          # <<interface>> Repository<T, ID>
    @abstractmethod
    def find_by_id(self, id_: int) -> Optional[T]: ...
    @abstractmethod
    def find_all(self) -> list[T]: ...
    @abstractmethod
    def save(self, entity: T) -> T: ...
    @abstractmethod
    def delete_by_id(self, id_: int) -> None: ...

class BaseSqlRepository(Repository[T]):     # BaseJdbcRepository in the diagram
    table = ""
    id_column = ""

    def __init__(self):
        self.cm = ConnectionManager()

    @abstractmethod
    def map_row(self, row: sqlite3.Row) -> T: ...
    @abstractmethod
    def to_params(self, entity: T) -> dict: ...

    def find_by_id(self, id_):
        row = self.cm.conn.execute(
            f"SELECT * FROM {self.table} WHERE {self.id_column}=?", (id_,)).fetchone()
        return self.map_row(row) if row else None

    def find_all(self):
        rows = self.cm.conn.execute(f"SELECT * FROM {self.table}").fetchall()
        return [self.map_row(r) for r in rows]

    def save(self, entity):
        params = self.to_params(entity)
        cols = ", ".join(params)
        marks = ", ".join(f":{k}" for k in params)
        cur = self.cm.conn.execute(
            f"INSERT INTO {self.table} ({cols}) VALUES ({marks})", params)
        self.cm.commit()
        setattr(entity, self.id_column, cur.lastrowid)
        return entity

    def delete_by_id(self, id_):
        self.cm.conn.execute(
            f"DELETE FROM {self.table} WHERE {self.id_column}=?", (id_,))
        self.cm.commit()

class UserRepository(BaseSqlRepository[User]):
    table, id_column = "users", "user_id"

    def map_row(self, r):
        role = Role(r["role"])
        return ROLE_TO_CLASS[role](
            user_id=r["user_id"], email=r["email"], password_hash=r["password_hash"],
            role=role, first_name=r["first_name"], last_name=r["last_name"],
            phone=r["phone"], status=Status(r["status"]),
            created_at=datetime.fromisoformat(r["created_at"]),
            updated_at=datetime.fromisoformat(r["updated_at"]))

    def to_params(self, u):
        return dict(email=u.email, password_hash=u.password_hash, role=u.role.value,
                    first_name=u.first_name, last_name=u.last_name, phone=u.phone,
                    status=u.status.value, created_at=u.created_at.isoformat(),
                    updated_at=u.updated_at.isoformat())

    def find_by_email(self, email: str) -> Optional[User]:
        row = self.cm.conn.execute(
            "SELECT * FROM users WHERE email=?", (email,)).fetchone()
        return self.map_row(row) if row else None

# ---------- Demo ----------
SCHEMA = """
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('CUSTOMER','ID','ADMIN')),
    first_name TEXT, last_name TEXT, phone TEXT,
    status TEXT DEFAULT 'ACTIVE',
    created_at TEXT, updated_at TEXT
);"""

if __name__ == "__main__":
    ConnectionManager().conn.executescript(SCHEMA)
    repo = UserRepository()
    repo.save(Customer(email="amy@example.com", password_hash="x", first_name="Amy", last_name="Tan"))
    repo.save(InteriorDesigner(email="bob@studio.com", password_hash="y", first_name="Bob", last_name="Lim"))
    for u in repo.find_all():
        print(type(u).__name__, "|", u.get_full_name(), "|", u.role.value)
    print(type(repo.find_by_email("bob@studio.com")).__name__)
