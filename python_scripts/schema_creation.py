"""
schema_creation.py

Scans a folder of CSV files, infers column types, 
and generates a schema.sql file to create tables
and a Postgres schema.

Usage:
    python schema_creation.py

Requires:
    - CSV files placed in the folder defined by PATH
"""

import os
import csv
from pathlib import Path
from datetime import datetime

PATH = Path('./1-lh_nautical_csv')
OUTPUT_FILE = os.path.join("sql", "schema.sql")
SCHEMA_NAME = 'lighthouse'
# TABLE_LIST = [] # used to validate possible table for foreign keys to reference

# Defined to check for out of range numeric fields
BIGINT_MIN = -9223372036854775808
BIGINT_MAX = 9223372036854775807

DATE_FORMATS = ('%Y-%m-%d', '%Y-%m-%d %H:%M:%S', '%m/%d/%Y', '%d/%m/%Y')

# Defining functions to check types for inferrence
def is_int(value):
    try:
        int(value)
        return True
    except ValueError:
        return False


def is_float(value):
    try:
        float(value)
        return True
    except ValueError:
        return False


def is_date(value):
    for fmt in DATE_FORMATS:
        try:
            datetime.strptime(value, fmt)
            return True
        except ValueError:
            continue
    return False


def infer_column_types(filepath, num_columns):
    """Streaming through the file once to more efficiently 
    infer data types from analysis"""
    candidates = ['int'] * num_columns  # all start as int

    with open(filepath, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # skip header
        for row in reader:
            for i, value in enumerate(row):
                if value == '':
                    continue  # empty (null) values don't disqualify a type
                current = candidates[i]
                if current == 'int':
                    if is_int(value):
                        if not (BIGINT_MIN <= int(value) <= BIGINT_MAX):
                            candidates[i] = 'text'  # out of bigint range -> text, safest
                    elif is_date(value):
                        candidates[i] = 'timestamp'
                    elif is_float(value):
                        candidates[i] = 'float'
                    else:
                        candidates[i] = 'text'
                elif current == 'float':
                    if not is_float(value):
                        candidates[i] = 'text'
                elif current == 'timestamp':
                    if not is_date(value):
                        candidates[i] = 'text'
                # once 'text', stays 'text'

    type_map = {'int': 'BIGINT', 'float': 'DOUBLE PRECISION', 'timestamp': 'TIMESTAMP', 'text': 'TEXT'} # mapping to postgre type names
    return [type_map[c] for c in candidates]


def escape_value(value, col_type):
    """Handles quoting corrections according to data type"""
    if value == '':
        return 'NULL'
    if col_type in ('BIGINT', 'DOUBLE PRECISION'):
        return value
    # TEXT / TIMESTAMP -> quote and escape single quotes
    escaped = value.replace("'", "''")
    return f"'{escaped}'"


def write_create_table(out, table_name, header, data_types):
    # TABLE_LIST.append(table_name) # creates a list of valid tables for foreing key identification later
    out.write(f'CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.{table_name} (\n')
    column_lines = []
    for col_name, col_type in zip(header, data_types):
        column_lines.append(f'    "{col_name}" {col_type}')
    if column_lines[0] == '    "id" BIGINT': # checking for id to apply PK constraint
        column_lines[0] += ' PRIMARY KEY'
    out.write(',\n'.join(column_lines))
    out.write('\n);\n\n')

# def write_foreign_keys(out, tables_info):
#     """ This function handles the creation of foreign keys separetely
#     to avoid conflicts in table creation order and altering this rule
#     only after creating and populating all tables"""
#     for table_name, header in tables_info.items():
#         for col_name in header:
#             # checking if last digits are id while also excluding PK id and validating against valid tables
#             if '_id' in col_name[-3:] and col_name[:-3] + 's' in TABLE_LIST:
#                 constraint_name = f'fk_{table_name}_{col_name}'
#                 out.write(
#                     f'ALTER TABLE {SCHEMA_NAME}.{table_name} '
#                     f'ADD CONSTRAINT {constraint_name} '
#                     f'FOREIGN KEY ("{col_name}") '
#                     # col_name[:-3] strips the "_id" then an "s" is added: customer_id -> customers
#                     f'REFERENCES {SCHEMA_NAME}.{col_name[:-3]}s (id);\n'
#                 )
#     out.write('\n')

def main():
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as out:
        tables_info = {} 
        out.write(f'CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME};\n\n')

        for item in PATH.iterdir():
            if not item.is_file() or item.suffix.lower() != '.csv':
                continue

            print(f'Processing {item.name}...')
            table_name = item.stem.lower().replace(' ', '_')

            with open(item, mode='r', newline='', encoding='utf-8') as file:
                header = next(csv.reader(file))

            tables_info[table_name] = header
            data_types = infer_column_types(item, len(header))
            write_create_table(out, table_name, header, data_types)
            # write_inserts(out, item, table_name, data_types)

        # write_foreign_keys(out, tables_info)
        """commented this out since it would make the sql too big to upload
        it in one go to neon free version postgre DB and would hinder ingestion
        performance, not worth it since the FKs will not be useful in other parts
        of the challenge"""

    print(f'Done. SQL written to {OUTPUT_FILE}')


if __name__ == '__main__':
    main()