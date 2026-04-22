SELECT
  @@SERVERNAME AS server_name,
  CAST(SERVERPROPERTY('Edition') AS varchar(100)) AS edition,
  CAST(SERVERPROPERTY('ProductVersion') AS varchar(50)) AS product_version,
  SUSER_SNAME() AS login_name,
  DB_NAME() AS current_database;

SELECT
  IS_SRVROLEMEMBER('sysadmin')  AS is_sysadmin,
  IS_SRVROLEMEMBER('bulkadmin') AS is_bulkadmin;

IF DB_ID('DW_BOOTCAMP') IS NULL
BEGIN
    CREATE DATABASE DW_BOOTCAMP;
END;
GO

ALTER DATABASE DW_BOOTCAMP SET RECOVERY SIMPLE;
GO

USE DW_BOOTCAMP;
GO

SELECT DB_NAME() AS active_db;

USE DW_BOOTCAMP;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze AUTHORIZATION dbo');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver') EXEC('CREATE SCHEMA silver AUTHORIZATION dbo');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')   EXEC('CREATE SCHEMA gold   AUTHORIZATION dbo');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'meta')   EXEC('CREATE SCHEMA meta   AUTHORIZATION dbo');
GO

SELECT name AS schema_name
FROM sys.schemas
WHERE name IN ('bronze','silver','gold','meta')
ORDER BY name;

CREATE TABLE meta.etl_run (
    run_id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    pipeline_name   NVARCHAR(200) NOT NULL,
    run_start_utc   DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    run_end_utc     DATETIME2(0)  NULL,
    run_status      NVARCHAR(30)  NOT NULL DEFAULT 'RUNNING',  -- RUNNING/SUCCESS/FAILED
    triggered_by    NVARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    notes           NVARCHAR(1000) NULL
);
GO


CREATE TABLE meta.etl_audit (
    audit_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id          BIGINT NOT NULL,
    layer_name      NVARCHAR(20)  NOT NULL,  -- BRONZE/SILVER/GOLD
    object_name     NVARCHAR(256) NOT NULL,  -- schema.table or schema.view
    step_name       NVARCHAR(200) NOT NULL,  -- e.g., LOAD_BRONZE_CRM
    row_count       BIGINT NULL,
    event_time_utc  DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    status          NVARCHAR(30) NOT NULL,   -- STARTED/SUCCESS/FAILED
    message         NVARCHAR(2000) NULL,
    CONSTRAINT fk_etl_audit_run
      FOREIGN KEY (run_id) REFERENCES meta.etl_run(run_id)
);
GO

SELECT s.name AS schema_name, t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = 'meta'
ORDER BY t.name;


SELECT DB_NAME() AS active_db;

SELECT name AS schema_name
FROM sys.schemas
WHERE name IN ('bronze','silver','gold','meta')
ORDER BY name;


SELECT s.name AS schema_name, t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name IN ('bronze','silver','gold')
ORDER BY s.name, t.name;


