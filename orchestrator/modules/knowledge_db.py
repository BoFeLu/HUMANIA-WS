import psycopg2

def get_connection():

    conn = psycopg2.connect(
        host="localhost",
        database="ultrahumania_knowledge",
        user="postgres",
        password="postgres",
        connect_timeout=5
    )

    return conn


def fetch_recent_knowledge(limit=5):

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT title, content
        FROM knowledge_nodes
        ORDER BY created_at DESC
        LIMIT %s
    """, (limit,))

    rows = cur.fetchall()

    context_lines = []

    for title, content in rows:
        context_lines.append(f"{title}: {content}")

    cur.close()
    conn.close()

    return "\n".join(context_lines)
