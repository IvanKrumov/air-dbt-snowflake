"""
Snowflake Connection Configuration
Use this script to test your connection and load data into Snowflake
"""

import snowflake.connector
import os
from typing import Dict

def get_snowflake_connection():
    """
    Create a Snowflake connection using credentials from environment variables
    or replace with your actual credentials
    """
    conn = snowflake.connector.connect(
        user=os.getenv('SNOWFLAKE_USER', 'YOUR_USERNAME'),
        password=os.getenv('SNOWFLAKE_PASSWORD', 'YOUR_PASSWORD'),
        account=os.getenv('SNOWFLAKE_ACCOUNT', 'YOUR_ACCOUNT'),
        warehouse=os.getenv('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH'),
        database=os.getenv('SNOWFLAKE_DATABASE', 'AIR_QUALITY_DB'),
        schema=os.getenv('SNOWFLAKE_SCHEMA', 'RAW_DATA'),
        role=os.getenv('SNOWFLAKE_ROLE', 'ACCOUNTADMIN')
    )
    return conn

def test_connection():
    """Test the Snowflake connection"""
    try:
        conn = get_snowflake_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT CURRENT_VERSION(), CURRENT_USER(), CURRENT_ROLE()")
        result = cursor.fetchone()
        print("✓ Connected to Snowflake successfully!")
        print(f"  Version: {result[0]}")
        print(f"  User: {result[1]}")
        print(f"  Role: {result[2]}")
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        return False

def setup_schema():
    """Create database and schema for air quality data"""
    conn = get_snowflake_connection()
    cursor = conn.cursor()

    try:
        # Create database
        cursor.execute("CREATE DATABASE IF NOT EXISTS AIR_QUALITY_DB")
        print("✓ Database AIR_QUALITY_DB created/exists")

        # Use database
        cursor.execute("USE DATABASE AIR_QUALITY_DB")

        # Create schema
        cursor.execute("CREATE SCHEMA IF NOT EXISTS RAW_DATA")
        print("✓ Schema RAW_DATA created/exists")

        # Create table
        cursor.execute("""
            CREATE OR REPLACE TABLE RAW_DATA.BULGARIA_AIR_MEASUREMENTS (
                station_code VARCHAR(50),
                sampling_point VARCHAR(100),
                pollutant VARCHAR(20),
                measurement_date DATE,
                measurement_time TIME,
                concentration FLOAT,
                unit VARCHAR(20),
                validity INT,
                verification INT,
                data_coverage FLOAT,
                country_code VARCHAR(2),
                downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
            )
        """)
        print("✓ Table BULGARIA_AIR_MEASUREMENTS created")

        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"✗ Schema setup failed: {e}")
        cursor.close()
        conn.close()
        return False

if __name__ == "__main__":
    print("Testing Snowflake connection...")
    if test_connection():
        print("\nSetting up schema...")
        setup_schema()
