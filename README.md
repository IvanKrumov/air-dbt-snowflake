# Air Quality Data Pipeline with Snowflake

Pipeline for downloading European air quality data and loading it into Snowflake for analysis.

## Project Overview

- **Data Source**: European Environment Agency (EEA) via AirBase API
- **Current Scope**: Bulgaria PM2.5 and PM10 measurements
- **Tech Stack**: Python 3.12, Snowflake, AirBase library

## Prerequisites

- Python 3.12+ with virtual environment (`dbt-snow/`)
- Snowflake account with credentials
- VS Code with Snowflake extension installed and connected

## Setup Instructions

### 1. Activate Virtual Environment

```bash
source dbt-snow/bin/activate
```

### 2. Set Snowflake Credentials

Create a `.env` file or set environment variables:

```bash
export SNOWFLAKE_USER='your_username'
export SNOWFLAKE_PASSWORD='your_password'
export SNOWFLAKE_ACCOUNT='your_account'
export SNOWFLAKE_WAREHOUSE='COMPUTE_WH'
export SNOWFLAKE_DATABASE='AIR_QUALITY_DB'
export SNOWFLAKE_SCHEMA='RAW_DATA'
export SNOWFLAKE_ROLE='ACCOUNTADMIN'
```

Or edit `snowflake_connection.py` directly with your credentials.

### 3. Test Snowflake Connection

```bash
python snowflake_connection.py
```

### 4. Setup Snowflake Schema (Option A: Using VS Code)

1. Open `setup_snowflake.sql` in VS Code
2. Ensure Snowflake extension is connected
3. Select all SQL statements (Ctrl+A / Cmd+A)
4. Right-click → "Execute SQL Statement"
5. Verify tables created successfully

### 4. Setup Snowflake Schema (Option B: Using Python)

```bash
python snowflake_connection.py
```

## Usage

### Option 1: Download Only (Original Script)

```bash
python ingest_task.py
```

Downloads data to `./data/bulgaria_verified/`

### Option 2: Download + Load to Snowflake

```bash
python ingest_and_load.py
```

Downloads data and automatically loads it into Snowflake.

## Working with Data in VS Code

### Execute SQL Queries

1. Open `queries.sql` in VS Code
2. Select the query you want to run
3. Right-click → "Execute SQL Statement"
4. View results in the Output panel

### Useful Queries

- **Count records**: Check total rows loaded
- **View sample data**: See first 10 rows
- **Pollutant analysis**: Average concentrations by pollutant
- **Station analysis**: Most active monitoring stations
- **Time series**: Daily/monthly trends
- **Data quality**: Check for nulls and verification status
- **Air quality alerts**: Find days exceeding WHO guidelines

## File Structure

```
air-dbt-snowflake/
├── ingest_task.py              # Original: Download only
├── ingest_and_load.py          # Enhanced: Download + Load to Snowflake
├── snowflake_connection.py     # Connection utilities
├── setup_snowflake.sql         # Database/table setup
├── queries.sql                 # Analysis queries
├── dbt-snow/                   # Python virtual environment
└── data/                       # Downloaded CSV files (gitignored)
```

## Next Steps

1. **Expand Data Coverage**: Modify scripts to download more countries/pollutants
2. **Setup dbt**: Create transformation models for analytics
3. **Schedule Pipeline**: Use Airflow/cron to run daily
4. **Create Dashboards**: Connect Tableau/PowerBI to Snowflake
5. **Add Data Quality Tests**: Implement validation checks

## Troubleshooting

### Connection Issues

- Verify Snowflake credentials in `.env` or `snowflake_connection.py`
- Check network access to Snowflake account
- Ensure role has necessary permissions (CREATE DATABASE, CREATE TABLE)

### Data Loading Issues

- Verify CSV files exist in `./data/bulgaria_verified/`
- Check table schema matches CSV columns
- Review Snowflake warehouse is running

### VS Code Extension Issues

- Reconnect Snowflake extension
- Check active warehouse and database
- Ensure SQL statements are properly selected before execution

## Resources

- [AirBase Documentation](https://airbase.readthedocs.io/)
- [Snowflake Python Connector](https://docs.snowflake.com/en/user-guide/python-connector)
- [EEA Air Quality Portal](https://www.eea.europa.eu/data-and-maps/data/aqereporting-8)
