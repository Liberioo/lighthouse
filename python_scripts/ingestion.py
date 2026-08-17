"""
ingestion.py

Executes a generated schema.sql file (schema and tables creation)
against a Postgres database, then loads each CSV in the source folder,
generating and executing batched INSERT statements as it reads the
data. Runs as a single transaction so a failure anywhere rolls back
the whole script.

Usage:
    python ingestion.py

Requires:
    - schema.sql present in the working directory
    - CSV files present in the folder defined by PATH in schema_creation.py
    - DATABASE_URL set in a .env file or the environment, pointing to
      the target Postgres instance
"""

import csv
import os
import psycopg2
from dotenv import load_dotenv
from pathlib import Path
from schema_creation import infer_column_types, escape_value

load_dotenv()

PATH = Path('./1-lh_nautical_csv')
SCHEMA_NAME = 'lighthouse'
BATCH_SIZE = 500  # rows per INSERT statement


def run_sql_file(cur, sql_path):
    with open(sql_path, 'r', encoding='utf-8') as f:
        sql_script = f.read()
    cur.execute(sql_script)

def load_csv(cur, filepath, table_name):
    """Infers column types (same logic used to build schema.sql), then
    streams the CSV, generating and executing batched INSERT statements
    against the table already created by schema.sql."""
    with open(filepath, mode='r', newline='', encoding='utf-8') as file:
        header = next(csv.reader(file))
    data_types = infer_column_types(filepath, len(header))

    with open(filepath, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # skip header

        batch = []
        for row in reader:
            values = [escape_value(v, t) for v, t in zip(row, data_types)]
            batch.append(f"({', '.join(values)})") # adds data up to batch size
            if len(batch) >= BATCH_SIZE: # deals with executing an insert statement for batch
                insert_sql = f'INSERT INTO {SCHEMA_NAME}.{table_name} VALUES\n' + ',\n'.join(batch) + ';'
                cur.execute(insert_sql)
                batch = [] # empties batch loaded for next one

        if batch:  # flush remainder if less than batch size info in last batch
            insert_sql = f'INSERT INTO {SCHEMA_NAME}.{table_name} VALUES\n' + ',\n'.join(batch) + ';'
            cur.execute(insert_sql)

def run_ingestion(sql_path, connection_url):
    conn = psycopg2.connect(connection_url)
    conn.autocommit = False  # run as one transaction; rollback on failure
    try:
        with conn.cursor() as cur:
            run_sql_file(cur, sql_path)

            for item in PATH.iterdir():
                if not item.is_file() or item.suffix.lower() != '.csv':
                    continue
                print(f'Loading {item.name}...')
                table_name = item.stem.lower().replace(' ', '_')
                load_csv(cur, item, table_name)

        conn.commit()
        print('SQL executed successfully.')
    except Exception as e:
        conn.rollback()
        print(f'Error executing SQL: {e}')
        raise
    finally:
        conn.close()

if __name__ == '__main__':
    connection_url = os.getenv('DATABASE_URL')
    run_ingestion('schema.sql', connection_url)