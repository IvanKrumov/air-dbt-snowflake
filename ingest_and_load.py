"""
Enhanced Air Quality Data Ingestion and Snowflake Loading
Downloads data from AirBase and loads it into Snowflake
"""

import os
import airbase
import pandas as pd
import snowflake.connector
from pathlib import Path
from snowflake_connection import get_snowflake_connection

def download_air_quality_data():
    """Download air quality data from AirBase"""
    data_dir = "./data/bulgaria_verified"
    os.makedirs(data_dir, exist_ok=True)

    print("Connecting to AirBase...")
    client = airbase.AirbaseClient()

    print("Creating request for Bulgaria PM2.5 and PM10 data...")
    request = client.request(
        "Verified",
        "BG",
        poll=["PM2.5", "PM10"]
    )

    print(f"Downloading to {data_dir}...")
    request.download(
        dir=data_dir,
        skip_existing=True
    )

    print("✓ Download complete!")
    return data_dir

def load_csv_to_snowflake(csv_file: str, table_name: str = "RAW_DATA.BULGARIA_AIR_MEASUREMENTS"):
    """Load a CSV file into Snowflake"""
    try:
        # Read CSV
        print(f"Reading {csv_file}...")
        df = pd.read_csv(csv_file)

        # Display sample
        print(f"  Rows: {len(df)}, Columns: {len(df.columns)}")
        print(f"  Columns: {', '.join(df.columns[:5])}...")

        # Connect to Snowflake
        conn = get_snowflake_connection()
        cursor = conn.cursor()

        # Use database and schema
        cursor.execute("USE DATABASE AIR_QUALITY_DB")
        cursor.execute("USE SCHEMA RAW_DATA")

        # Write DataFrame to Snowflake
        # Note: You'll need to map CSV columns to table columns
        from snowflake.connector.pandas_tools import write_pandas

        success, nchunks, nrows, _ = write_pandas(
            conn=conn,
            df=df,
            table_name=table_name.split('.')[-1],
            database='AIR_QUALITY_DB',
            schema='RAW_DATA',
            auto_create_table=True
        )

        if success:
            print(f"✓ Loaded {nrows} rows into {table_name}")
        else:
            print(f"✗ Failed to load data")

        cursor.close()
        conn.close()
        return success

    except Exception as e:
        print(f"✗ Error loading {csv_file}: {e}")
        return False

def load_all_data(data_dir: str):
    """Load all CSV files from data directory into Snowflake"""
    csv_files = list(Path(data_dir).glob("**/*.csv"))

    if not csv_files:
        print(f"No CSV files found in {data_dir}")
        return

    print(f"\nFound {len(csv_files)} CSV files to load")

    for i, csv_file in enumerate(csv_files, 1):
        print(f"\n[{i}/{len(csv_files)}] Processing {csv_file.name}...")
        load_csv_to_snowflake(str(csv_file))

def main():
    """Main execution flow"""
    print("=" * 60)
    print("Air Quality Data Pipeline: Download → Snowflake")
    print("=" * 60)

    # Step 1: Download data
    data_dir = download_air_quality_data()

    # Step 2: Load into Snowflake
    print("\n" + "=" * 60)
    print("Loading data into Snowflake...")
    print("=" * 60)
    load_all_data(data_dir)

    print("\n✓ Pipeline complete!")

if __name__ == "__main__":
    main()
