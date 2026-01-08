-- Air Quality Database Setup
-- Execute these commands in VS Code using the Snowflake extension
-- Right-click and select "Execute SQL Statement" for each block

-- ============================================================
-- STEP 1: Create Database and Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS AIR_QUALITY_DB;
USE DATABASE AIR_QUALITY_DB;

CREATE SCHEMA IF NOT EXISTS RAW_DATA;
USE SCHEMA RAW_DATA;

-- ============================================================
-- STEP 2: Create Tables
-- ============================================================

-- Main table for air quality measurements
CREATE OR REPLACE TABLE BULGARIA_AIR_MEASUREMENTS (
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
    country_code VARCHAR(2) DEFAULT 'BG',
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- STEP 3: Create File Format for CSV Loading
-- ============================================================

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- ============================================================
-- STEP 4: Create Stage for Data Loading
-- ============================================================

CREATE OR REPLACE STAGE AIR_QUALITY_STAGE
    FILE_FORMAT = CSV_FORMAT;

-- ============================================================
-- Verify Setup
-- ============================================================

-- Show all tables
SHOW TABLES IN SCHEMA RAW_DATA;

-- Describe table structure
DESCRIBE TABLE BULGARIA_AIR_MEASUREMENTS;

-- Show file formats
SHOW FILE FORMATS;

-- Show stages
SHOW STAGES;
