import os
import logging
from datetime import datetime, timedelta
from typing import Optional

import jwt
from fastapi import FastAPI, Depends, Header, HTTPException
from database import engine
from sqlalchemy import text

from jwt import InvalidTokenError

# Configure logging BEFORE creating logger
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# JWT secret (can be set in backend/.env as SECRET_KEY)
# Use a secret of at least 32 chars for HS256 (PyJWT recommendation)
SECRET_KEY = os.getenv('SECRET_KEY')
logger.info(f'Backend initialized with SECRET_KEY: {SECRET_KEY[:10]}...')

app = FastAPI()


# @app.get("/")
# def home():
#     return {
#         "message": "Coop Loto API fonctionne"
#     }


# @app.get("/")
# def test():
#     return {
#         "database": str(engine.url)
#     }

@app.get("/")
def test():

    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT version();"))
            version = result.scalar()

        return {
            "status": "OK",
            "postgres": version
        }

    except Exception as e:
        return {
            "status": "ERROR",
            "message": str(e)
        }
    

@app.get("/tables")
def get_tables():

    query = text("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        ORDER BY table_name;
    """)

    with engine.connect() as connection:
        result = connection.execute(query)

        tables = [
            row[0]
            for row in result
        ]

    return {
        "tables": tables
    }


def get_all_from_table(table_name: str):

    query = text(
        f"""
        SELECT *
        FROM "{table_name}";
        """
    )

    with engine.connect() as connection:
        result = connection.execute(query)

        rows = result.mappings().all()

    return rows


# def _get_user_id_from_token(authorization: Optional[str] = Header(None)):
#     if not authorization:
#         logger.warning('[auth] Missing authorization header')
#         raise HTTPException(status_code=401, detail='Missing authorization')

#     try:
#         logger.info(f'[auth] Authorization header: {authorization[:50]}...')
#         scheme, token = authorization.split()
#         if scheme.lower() != 'bearer':
#             logger.warning(f'[auth] Invalid auth scheme: {scheme}')
#             raise HTTPException(status_code=401, detail='Invalid auth scheme')
#         try:
#             payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
#             logger.info(f'[auth] token decoded: sub={payload.get("sub")}')
#         except Exception as e:
#             logger.error(f'[auth] token decode error: {e}')
#             raise
#         user_id = payload.get('sub')
#         if user_id is None:
#             logger.warning('[auth] No sub claim in token')
#             raise HTTPException(status_code=401, detail='Invalid token')
#         logger.info(f'[auth] user_id extracted: {user_id}')
#         return int(user_id)
#     except HTTPException:
#         raise
#     except Exception as e:
#         logger.error(f'[auth] Unexpected error: {e}')
#         raise HTTPException(status_code=401, detail='Invalid token')

def _get_user_id_from_token(
    authorization: Optional[str] = Header(None)
):
    if authorization is None:
        logger.warning("[AUTH] Missing Authorization header")
        raise HTTPException(status_code=401, detail="Missing authorization")

    try:
        logger.info(f"[AUTH] Header = {authorization}")

        scheme, token = authorization.split()

        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid auth scheme")

        logger.info(f"[AUTH] JWT = {token}")

        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=["HS256"]
        )

        logger.info(f"[AUTH] Payload = {payload}")

        return int(payload["sub"])

    except InvalidTokenError as e:
        logger.error(f"[AUTH] Invalid JWT : {e}")
        raise HTTPException(status_code=401, detail="Invalid token")

    except HTTPException:
        raise

    except Exception as e:
        logger.exception("[AUTH] Unexpected error")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/me")
def me(user_id: int = Depends(_get_user_id_from_token)):
    query = text("""
        SELECT id, pseudo
        FROM "Users"
        WHERE id = :id
    """)

    with engine.connect() as conn:
        user = conn.execute(query, {"id": user_id}).mappings().first()

    return user

@app.post('/login')
def login(body: dict):
    pseudo = body.get('pseudo')
    password = body.get('password')
    if not pseudo or not password:
        raise HTTPException(status_code=400, detail='Missing credentials')

    query = text('''
        SELECT * FROM "Users" WHERE pseudo = :pseudo
    ''')

    with engine.connect() as connection:
        result = connection.execute(query, {'pseudo': pseudo}).mappings().first()

    if not result:
        raise HTTPException(status_code=401, detail='Invalid credentials')

    # NOTE: plaintext password comparison - replace with secure hash check if needed
    if result.get('password') != password:
        raise HTTPException(status_code=401, detail='Invalid credentials')

    payload = {
        'sub': str(result.get('id')),
        'pseudo': result.get('pseudo'),
        'exp': datetime.utcnow() + timedelta(days=7)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')

    return {'token': token, 'pseudo': result.get('pseudo'), 'id': result.get('id')}


@app.get('/my_groups')
def my_groups(user_id: int = Depends(_get_user_id_from_token)):
    logger.info(f'[my_groups] requested for user_id={user_id}')

    query_groups = text('''
        SELECT g.*
        FROM "Groups" g
        JOIN "Members" m ON g.id = m."group"
        WHERE m."user" = :uid
        ORDER BY g.id
    ''')

    query_members = text('''
        SELECT * FROM "Members" WHERE "user" = :uid ORDER BY id
    ''')

    with engine.connect() as connection:
        res_g = connection.execute(query_groups, {'uid': user_id})
        groups = res_g.mappings().all()

        res_m = connection.execute(query_members, {'uid': user_id})
        members = res_m.mappings().all()

    logger.info(f'[my_groups] found groups_count={len(groups)} members_count={len(members)}')

    return {'groups': groups, 'members': members}


@app.get("/groups")
def get_groups():

    return get_all_from_table("Groups")


@app.get("/members")
def get_members():

    return get_all_from_table("Members")


@app.get("/groups/{group_id}/members")
def get_group_members(
    group_id: int,
    user_id: int = Depends(_get_user_id_from_token)
):
    logger.info(
        f'[group_members] requested for group_id={group_id} by user_id={user_id}'
    )

    query = text("""
        SELECT
            m.id AS member_id,
            m."group" AS group_id,
            m."user" AS user_id,
            u.pseudo
        FROM "Members" m
        JOIN "Users" u
            ON u.id = m."user"
        WHERE m."group" = :group_id
          AND EXISTS (
              SELECT 1
              FROM "Members" my_membership
              WHERE my_membership."group" = :group_id
                AND my_membership."user" = :user_id
          )
        ORDER BY m.id
    """)

    with engine.connect() as connection:
        members = connection.execute(
            query,
            {
                "group_id": group_id,
                "user_id": user_id,
            }
        ).mappings().all()

    logger.info(
        f'[group_members] found members_count={len(members)}'
    )

    return {
        "group_id": group_id,
        "members": members,
    }


@app.get("/split_rules")
def get_split_rules():

    return get_all_from_table("Split_rules")


@app.get("/users")
def get_users():

    return get_all_from_table("Users")