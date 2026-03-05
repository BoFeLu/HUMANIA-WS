import psycopg2

def get_uh_status():
    conn = psycopg2.connect("dbname=ultrahumania user=postgres password=TU_PASSWORD")
    cur = conn.cursor()
    
    print("--- ESTADO DEL ULTRASISTEMA UH ---")
    cur.execute("SELECT nombre_archivo, ruta_completa FROM inventory_assets WHERE categoria = 'HUMANIA' LIMIT 5;")
    for row in cur.fetchall():
        print(f"LEY ACTIVA: {row[0]} en {row[1]}")
    
    cur.execute("SELECT accion, fecha_accion FROM audit_trail ORDER BY fecha_accion DESC LIMIT 1;")
    last_act = cur.fetchone()
    print(f"ÚLTIMA ACCIÓN NOTARIO: {last_act[0]} el {last_act[1]}")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    get_uh_status()