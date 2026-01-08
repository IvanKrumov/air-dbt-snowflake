-- Setup Git Integration with Snowflake
-- This allows you to access your VS Code files in Snowflake workspaces
-- Execute these commands in VS Code using the Snowflake extension

USE DATABASE AIR_QUALITY_DB;
USE SCHEMA RAW_DATA;

-- ============================================================
-- STEP 1: Create API Integration for GitHub
-- ============================================================
-- This needs ACCOUNTADMIN role
-- Replace with your actual values

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/IvanKrumov/')
  ENABLED = TRUE;

-- Verify the integration was created
SHOW API INTEGRATIONS LIKE 'git_api_integration';

-- ============================================================
-- STEP 2: Create Secret for GitHub Authentication
-- ============================================================
-- You'll need a GitHub Personal Access Token
-- Create one at: https://github.com/settings/tokens
-- Required scopes: repo (Full control of private repositories)

CREATE OR REPLACE SECRET git_secret
  TYPE = PASSWORD
  USERNAME = 'IvanKrumov'  -- Your GitHub username
  PASSWORD = 'YOUR_GITHUB_TOKEN';  -- Replace with your GitHub token

-- ============================================================
-- STEP 3: Create Git Repository Object
-- ============================================================
-- This creates a repository stage synced with your GitHub repo

CREATE OR REPLACE GIT REPOSITORY air_dbt_repo
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/IvanKrumov/air-dbt-snowflake'
  GIT_CREDENTIALS = git_secret;

-- ============================================================
-- STEP 4: Fetch Repository Content
-- ============================================================
-- Sync the repository to pull latest changes from GitHub

ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- ============================================================
-- STEP 5: List Files in Repository
-- ============================================================
-- View all files from your VS Code project in Snowflake

-- List all files
LIST @air_dbt_repo/branches/main;

-- Or for your claude branch
LIST @air_dbt_repo/branches/claude/explain-codebase-mk5x2988ttt6335a-NhCyV;

-- ============================================================
-- STEP 6: Read Files from Repository
-- ============================================================
-- View content of specific files

-- View Python files
SELECT
    RELATIVE_PATH,
    SIZE,
    LAST_MODIFIED
FROM DIRECTORY(@air_dbt_repo/branches/main)
WHERE RELATIVE_PATH LIKE '%.py';

-- View SQL files
SELECT
    RELATIVE_PATH,
    SIZE,
    LAST_MODIFIED
FROM DIRECTORY(@air_dbt_repo/branches/main)
WHERE RELATIVE_PATH LIKE '%.sql';

-- ============================================================
-- STEP 7: Use Files in Stored Procedures/UDFs
-- ============================================================
-- Example: Create a stored procedure using your Python code

CREATE OR REPLACE PROCEDURE run_ingestion()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'pandas')
IMPORTS = ('@air_dbt_repo/branches/main/snowflake_connection.py')
HANDLER = 'run'
AS
$$
def run(session):
    # Your code from the repository can be used here
    return "Ingestion completed"
$$;

-- ============================================================
-- Maintenance Commands
-- ============================================================

-- Refresh repository (pull latest changes from GitHub)
ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- Show repository details
SHOW GIT REPOSITORIES;

-- Describe repository
DESCRIBE GIT REPOSITORY air_dbt_repo;

-- Drop repository (if needed)
-- DROP GIT REPOSITORY air_dbt_repo;
