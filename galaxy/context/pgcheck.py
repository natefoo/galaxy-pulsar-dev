#!/usr/bin/env python3
import sys
import time
import psycopg2

sql = 'SELECT version_num FROM alembic_version'

while True:
    try:
        conn = psycopg2.connect('postgresql://galaxy:galaxy@postgres/galaxy')
        break
    except psycopg2.OperationalError as e:
        print(f"pgcheck.py: waiting for postgres: {e}")
        time.sleep(1)

print(f"pgcheck.py: postgres is alive")

if len(sys.argv) == 1:
    sys.exit(0)

cur = conn.cursor()

while True:
    try:
        cur.execute(sql)
        break
    except psycopg2.errors.UndefinedTable as e:
        print(f"pgcheck.py: waiting for alembic_version table: {e}")
        conn.rollback()
        time.sleep(1)

print(f"pgcheck.py: alembic_version table exists")

while True:
    cur.execute(sql)
    row = cur.fetchone()
    if row:
        print(f"pgcheck.py: galaxy db version is {row[0]}")
        break
    else:
        print("pgcheck.py: waiting for version row")

