# Snowflake Git Integration Guide

## Overview

Snowflake's Git integration allows you to connect your GitHub repository directly to Snowflake, making your VS Code files accessible in Snowflake workspaces. This enables a seamless development workflow where you code locally and sync to Snowflake.

## Benefits

✅ **Develop Locally** - Write code in VS Code with all your favorite extensions
✅ **Version Control** - Keep all code in Git for collaboration and history
✅ **Auto-Sync** - Changes in GitHub are available in Snowflake after fetch
✅ **Use in Snowflake** - Reference files in stored procedures, UDFs, and more
✅ **Single Source of Truth** - No manual file uploads or copy-pasting

## Workflow

```
VS Code → Git Commit → GitHub → Snowflake Fetch → Available in Snowflake
```

1. **Develop** in VS Code (write Python scripts, SQL files, etc.)
2. **Commit** changes to your local Git repository
3. **Push** to GitHub
4. **Fetch** in Snowflake to sync latest changes
5. **Use** files in Snowflake stored procedures, UDFs, or queries

## Setup Steps

### 1. Create GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click **"Generate new token (classic)"**
3. Select scopes:
   - ✅ `repo` (Full control of private repositories)
4. Generate and **copy the token** (you won't see it again!)

### 2. Execute Setup SQL in VS Code

Open `setup_git_integration.sql` in VS Code and execute:

**Step-by-step:**

```sql
-- 1. Create API Integration (needs ACCOUNTADMIN)
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/IvanKrumov/')
  ENABLED = TRUE;

-- 2. Create Secret with your GitHub token
CREATE OR REPLACE SECRET git_secret
  TYPE = PASSWORD
  USERNAME = 'IvanKrumov'
  PASSWORD = 'ghp_your_token_here';  -- Paste your token here

-- 3. Create Git Repository Object
CREATE OR REPLACE GIT REPOSITORY air_dbt_repo
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/IvanKrumov/air-dbt-snowflake'
  GIT_CREDENTIALS = git_secret;

-- 4. Fetch repository content
ALTER GIT REPOSITORY air_dbt_repo FETCH;
```

### 3. Verify Setup

```sql
-- List files from main branch
LIST @air_dbt_repo/branches/main;

-- View directory structure
SELECT
    RELATIVE_PATH,
    SIZE,
    LAST_MODIFIED
FROM DIRECTORY(@air_dbt_repo/branches/main);
```

You should see all your files:
- `ingest_task.py`
- `ingest_and_load.py`
- `snowflake_connection.py`
- `setup_snowflake.sql`
- `queries.sql`
- etc.

## Using Your Files in Snowflake

### Access Files in Worksheets

Once set up, you can reference files from your repository:

```sql
-- View file content
SELECT $1 FROM @air_dbt_repo/branches/main/queries.sql;

-- List Python files
SELECT RELATIVE_PATH
FROM DIRECTORY(@air_dbt_repo/branches/main)
WHERE RELATIVE_PATH LIKE '%.py';
```

### Use in Stored Procedures

```sql
CREATE OR REPLACE PROCEDURE run_data_quality_check()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('pandas', 'snowflake-snowpark-python')
IMPORTS = ('@air_dbt_repo/branches/main/snowflake_connection.py')
HANDLER = 'main'
AS
$$
import snowflake_connection

def main(session):
    # Use functions from your VS Code file
    conn = snowflake_connection.get_snowflake_connection()
    # Your logic here
    return "Check completed"
$$;
```

### Use in UDFs

```sql
-- Create UDF using repository files
CREATE OR REPLACE FUNCTION process_data(input STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
IMPORTS = ('@air_dbt_repo/branches/main/your_module.py')
HANDLER = 'your_module.process';
```

## Daily Workflow

### In VS Code (Local Development)

```bash
# 1. Make changes to your files
vim ingest_and_load.py

# 2. Commit changes
git add .
git commit -m "Update ingestion logic"

# 3. Push to GitHub
git push origin claude/explain-codebase-mk5x2988ttt6335a-NhCyV
```

### In Snowflake (Sync Changes)

```sql
-- Fetch latest changes from GitHub
ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- Verify new files/changes are available
LIST @air_dbt_repo/branches/claude/explain-codebase-mk5x2988ttt6335a-NhCyV;
```

That's it! Your VS Code changes are now available in Snowflake.

## Working with Different Branches

```sql
-- List branches
SHOW GIT BRANCHES IN air_dbt_repo;

-- Access main branch files
LIST @air_dbt_repo/branches/main;

-- Access feature branch files
LIST @air_dbt_repo/branches/claude/explain-codebase-mk5x2988ttt6335a-NhCyV;

-- Use file from specific branch in stored procedure
IMPORTS = ('@air_dbt_repo/branches/main/script.py')
```

## Viewing Files in Snowsight (Web UI)

1. Navigate to **Snowsight** (Snowflake's web interface)
2. Go to **Data** → **Databases** → **AIR_QUALITY_DB**
3. Find **Git Repositories** section
4. Click on **air_dbt_repo**
5. Browse branches and view files

## Automation Example

```sql
-- Create a task that uses your repository code
CREATE OR REPLACE TASK daily_ingestion
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 2 * * * UTC'
AS
  CALL run_ingestion();  -- Uses code from your Git repo
```

## Troubleshooting

### Issue: "API Integration not found"
**Solution**: Make sure you're using `ACCOUNTADMIN` role when creating API integration.

### Issue: "Invalid credentials"
**Solution**:
- Check your GitHub token is correct
- Ensure token has `repo` scope
- Verify token hasn't expired

### Issue: "Repository not found"
**Solution**:
- Check repository URL is correct
- Ensure repository is accessible with your token
- Try public repository first for testing

### Issue: "Files not showing up after push"
**Solution**: Run `ALTER GIT REPOSITORY air_dbt_repo FETCH;` to sync latest changes.

## Best Practices

1. **Use Separate Branches** - Develop on feature branches, sync stable code to main
2. **Fetch Regularly** - Run `ALTER GIT REPOSITORY ... FETCH` to get latest changes
3. **Version Control Everything** - Keep SQL, Python, and config files in Git
4. **Use Imports** - Reference shared code modules in stored procedures
5. **Document Dependencies** - Track which Snowflake objects depend on which files
6. **Automate Syncing** - Create a task to fetch repository updates regularly

## Advanced: Automatic Sync Task

```sql
-- Automatically fetch repository updates daily
CREATE OR REPLACE TASK sync_git_repo
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 */6 * * * UTC'  -- Every 6 hours
AS
  ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- Enable the task
ALTER TASK sync_git_repo RESUME;
```

## Resources

- [Snowflake Git Integration Documentation](https://docs.snowflake.com/en/developer-guide/git/git-overview)
- [CREATE GIT REPOSITORY Reference](https://docs.snowflake.com/en/sql-reference/sql/create-git-repository)
- [Git Operations in Snowflake](https://docs.snowflake.com/en/developer-guide/git/git-operations)

## Summary

With Git integration:
- ✅ Your **VS Code files** are accessible in **Snowflake workspaces**
- ✅ You can **browse, view, and use** files from your repository
- ✅ Changes you **commit and push** become available after **fetching**
- ✅ You maintain a **single source of truth** in Git
- ✅ You can **develop locally** and **deploy to Snowflake** seamlessly

**Next Step**: Execute `setup_git_integration.sql` to connect your repository!
