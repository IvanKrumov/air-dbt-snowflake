-- Air Quality Data Queries
-- Use these queries in VS Code with the Snowflake extension
-- Select the query you want to run and execute it

USE DATABASE AIR_QUALITY_DB;
USE SCHEMA RAW_DATA;

-- ============================================================
-- Basic Data Exploration
-- ============================================================

-- Count total records
SELECT COUNT(*) AS total_records
FROM BULGARIA_AIR_MEASUREMENTS;

-- View sample data
SELECT *
FROM BULGARIA_AIR_MEASUREMENTS
LIMIT 10;

-- Check date range
SELECT
    MIN(measurement_date) AS earliest_date,
    MAX(measurement_date) AS latest_date,
    DATEDIFF(day, MIN(measurement_date), MAX(measurement_date)) AS days_covered
FROM BULGARIA_AIR_MEASUREMENTS;

-- ============================================================
-- Pollutant Analysis
-- ============================================================

-- Summary by pollutant
SELECT
    pollutant,
    COUNT(*) AS measurement_count,
    ROUND(AVG(concentration), 2) AS avg_concentration,
    ROUND(MIN(concentration), 2) AS min_concentration,
    ROUND(MAX(concentration), 2) AS max_concentration,
    unit
FROM BULGARIA_AIR_MEASUREMENTS
GROUP BY pollutant, unit
ORDER BY pollutant;

-- ============================================================
-- Station Analysis
-- ============================================================

-- Most active monitoring stations
SELECT
    station_code,
    sampling_point,
    COUNT(*) AS measurement_count,
    COUNT(DISTINCT pollutant) AS pollutants_monitored
FROM BULGARIA_AIR_MEASUREMENTS
GROUP BY station_code, sampling_point
ORDER BY measurement_count DESC
LIMIT 10;

-- ============================================================
-- Time Series Analysis
-- ============================================================

-- Daily average by pollutant
SELECT
    measurement_date,
    pollutant,
    ROUND(AVG(concentration), 2) AS avg_concentration,
    COUNT(*) AS reading_count
FROM BULGARIA_AIR_MEASUREMENTS
GROUP BY measurement_date, pollutant
ORDER BY measurement_date DESC, pollutant
LIMIT 50;

-- Monthly averages
SELECT
    DATE_TRUNC('month', measurement_date) AS month,
    pollutant,
    ROUND(AVG(concentration), 2) AS avg_concentration,
    COUNT(*) AS reading_count
FROM BULGARIA_AIR_MEASUREMENTS
GROUP BY month, pollutant
ORDER BY month DESC, pollutant;

-- ============================================================
-- Data Quality Checks
-- ============================================================

-- Check for nulls
SELECT
    COUNT(*) AS total_rows,
    COUNT(station_code) AS has_station_code,
    COUNT(pollutant) AS has_pollutant,
    COUNT(concentration) AS has_concentration,
    COUNT(measurement_date) AS has_date
FROM BULGARIA_AIR_MEASUREMENTS;

-- Check verification status
SELECT
    verification,
    validity,
    COUNT(*) AS count
FROM BULGARIA_AIR_MEASUREMENTS
GROUP BY verification, validity
ORDER BY count DESC;

-- ============================================================
-- Air Quality Alerts (Example: PM2.5 WHO Guidelines)
-- ============================================================

-- WHO guideline: PM2.5 daily mean should not exceed 15 μg/m³
SELECT
    measurement_date,
    station_code,
    sampling_point,
    ROUND(AVG(concentration), 2) AS daily_avg_pm25,
    unit
FROM BULGARIA_AIR_MEASUREMENTS
WHERE pollutant = 'PM2.5'
GROUP BY measurement_date, station_code, sampling_point, unit
HAVING AVG(concentration) > 15
ORDER BY daily_avg_pm25 DESC
LIMIT 20;

-- ============================================================
-- Export Query Results
-- ============================================================

-- Recent high pollution days for PM2.5
SELECT
    measurement_date,
    pollutant,
    station_code,
    ROUND(AVG(concentration), 2) AS avg_concentration,
    unit
FROM BULGARIA_AIR_MEASUREMENTS
WHERE pollutant = 'PM2.5'
  AND measurement_date >= DATEADD(month, -3, CURRENT_DATE())
GROUP BY measurement_date, pollutant, station_code, unit
ORDER BY avg_concentration DESC
LIMIT 100;
