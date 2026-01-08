# Git Integration Quick Start

## 🚀 5-Minute Setup

### Prerequisites
- ✅ Snowflake extension in VS Code (already connected)
- ✅ GitHub repository (you have it: IvanKrumov/air-dbt-snowflake)
- ✅ ACCOUNTADMIN access in Snowflake

### Step 1: Create GitHub Token (2 min)
1. Go to: https://github.com/settings/tokens/new
2. Name it: "Snowflake Integration"
3. Select scope: ✅ `repo`
4. Click "Generate token"
5. **Copy the token** (starts with `ghp_`)

### Step 2: Execute in VS Code (3 min)

Open `setup_git_integration.sql` in VS Code, replace `YOUR_GITHUB_TOKEN`, and execute:

```sql
USE ROLE ACCOUNTADMIN;

-- 1. Create API Integration
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/IvanKrumov/')
  ENABLED = TRUE;

-- 2. Store GitHub Credentials
CREATE OR REPLACE SECRET git_secret
  TYPE = PASSWORD
  USERNAME = 'IvanKrumov'
  PASSWORD = 'ghp_your_token_here';  -- ← PASTE YOUR TOKEN HERE

-- 3. Connect Repository
CREATE OR REPLACE GIT REPOSITORY air_dbt_repo
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/IvanKrumov/air-dbt-snowflake'
  GIT_CREDENTIALS = git_secret;

-- 4. Sync Files
ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- 5. Verify (you should see all your files!)
LIST @air_dbt_repo/branches/main;
```

### ✅ Done!

Your VS Code files are now accessible in Snowflake.

## 📁 View Your Files

### In Snowflake Worksheets (VS Code):

```sql
-- List all files
LIST @air_dbt_repo/branches/main;

-- View Python files
SELECT RELATIVE_PATH, SIZE
FROM DIRECTORY(@air_dbt_repo/branches/main)
WHERE RELATIVE_PATH LIKE '%.py';

-- View SQL files
SELECT RELATIVE_PATH, SIZE
FROM DIRECTORY(@air_dbt_repo/branches/main)
WHERE RELATIVE_PATH LIKE '%.sql';
```

### In Snowsight (Web UI):
1. Go to **Data** → **Databases** → **AIR_QUALITY_DB**
2. Find **Git Repositories** section
3. Click **air_dbt_repo** → Browse files

## 🔄 Daily Workflow

### When You Make Changes:

**In VS Code:**
```bash
# Edit files
vim ingest_and_load.py

# Commit & push
git add .
git commit -m "Updated ingestion"
git push
```

**In Snowflake:**
```sql
-- Sync latest changes
ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- Files are now updated!
LIST @air_dbt_repo/branches/main;
```

## 💡 Use Cases

### 1. Run Python from Repository

```sql
CREATE OR REPLACE PROCEDURE run_ingestion()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('pandas')
IMPORTS = ('@air_dbt_repo/branches/main/snowflake_connection.py')
HANDLER = 'main';
```

### 2. Browse Files

```sql
-- See all files
SELECT * FROM DIRECTORY(@air_dbt_repo/branches/main);
```

### 3. Read File Content

```sql
-- View README content
SELECT $1 FROM @air_dbt_repo/branches/main/README.md;
```

## 🎯 Benefits

| Without Git Integration | With Git Integration |
|------------------------|---------------------|
| Copy-paste code manually | Auto-synced from GitHub |
| No version control in Snowflake | Full Git history available |
| Duplicate code management | Single source of truth |
| Manual updates | One command to sync |

## 🔧 Maintenance

```sql
-- Refresh repository (run after pushing changes)
ALTER GIT REPOSITORY air_dbt_repo FETCH;

-- View repository info
DESCRIBE GIT REPOSITORY air_dbt_repo;
SHOW GIT REPOSITORIES;
SHOW GIT BRANCHES IN air_dbt_repo;

-- View tags/commits
SHOW GIT TAGS IN air_dbt_repo;
```

## ❓ FAQ

**Q: Do I need to fetch every time I push?**
A: Yes, run `ALTER GIT REPOSITORY ... FETCH;` to sync changes.

**Q: Can I use private repositories?**
A: Yes! That's what the GitHub token is for.

**Q: Which branch should I use?**
A: Access any branch: `@air_dbt_repo/branches/BRANCH_NAME`

**Q: Can teammates access the same repo?**
A: Yes! Once set up, anyone with access to that Snowflake account can use it.

**Q: Does this affect my local files?**
A: No! This is read-only from GitHub to Snowflake.

## 📚 Full Documentation

See `GIT_INTEGRATION_GUIDE.md` for comprehensive documentation.

---

**Ready?** Execute `setup_git_integration.sql` now! 🚀
