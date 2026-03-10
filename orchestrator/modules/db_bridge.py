import psycopg2

def connect_db():

    conn = psycopg2.connect(
        dbname="ultrahumania",
        user="uh_core",
        host="localhost"
    )

    return conn
