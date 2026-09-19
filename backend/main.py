from fastapi import FastAPI
from database import engine
from sqlalchemy import text

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


@app.get("/groups")
def get_groups():

    return get_all_from_table("Groups")


@app.get("/members")
def get_members():

    return get_all_from_table("Members")


@app.get("/split_rules")
def get_split_rules():

    return get_all_from_table("Split_rules")


@app.get("/users")
def get_users():

    return get_all_from_table("Users")