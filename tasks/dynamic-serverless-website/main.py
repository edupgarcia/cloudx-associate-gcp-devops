import os
import json
import mysql.connector

db_creds = json.loads(os.environ['DB_CREDS'])
db_conn = mysql.connector.connect(
    host=db_creds['host'],
    user=db_creds['username'],
    password=db_creds['password']
)

def handler(request):
    cursor = db_conn.cursor()
    cursor.execute("SELECT NOW();")
    for x in cursor.fetchone():
        return str(x)

if __name__ == "__main__":
    print(handler())
