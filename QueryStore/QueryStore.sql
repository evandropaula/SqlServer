USE WideWorldImporters
GO

--=======================================================================>
-- CHECK IF QUERY STORE IS ENABLED
--=======================================================================>
-- The following query checks if the Query Store is enabled or not (0 = DISABLED, 1 = ENABLED)
SELECT
	compatibility_level,
	is_query_store_on
FROM
	sys.databases
WHERE
	database_id = DB_ID()
GO

-- Another option is the following query, which provides more detailed information about the query store current settings
-- Possible states are:
--		READ_ONLY	=	in case the database is in read-only mode, its store exceeded the quota, etc.;
--						check column readonly_reason for more details (https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-query-store-options-transact-sql);
--		ERROR		=	Query store is unhealthy. It can be recovered by running stored procedure sp_query_store_consistency_check;
SELECT * FROM sys.database_query_store_options


--=======================================================================>
-- ENABLE/DISABLE QUERY STORE
--=======================================================================>
-- Enable it
ALTER DATABASE CURRENT SET QUERY_STORE = ON

-- Disable it
ALTER DATABASE CURRENT SET QUERY_STORE = OFF
GO


--=======================================================================>
-- ENABLE WITH CUSTOM SETTINGS
--=======================================================================>
ALTER DATABASE CURRENT SET QUERY_STORE
	(
		OPERATION_MODE = READ_WRITE,
		CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), -- Number of days to retain data in the query store (Default = 30)
		DATA_FLUSH_INTERVAL_SECONDS = 300, -- Frequency at which data written to the query store is persisted to disk (Default = 900 = 15 minutes)
		INTERVAL_LENGTH_MINUTES = 60, -- Time interval at which runtime execution statistics data is aggregated into the query store (Default = 60)
		MAX_STORAGE_SIZE_MB = 100,
		QUERY_CAPTURE_MODE = ALL,
		SIZE_BASED_CLEANUP_MODE = AUTO -- Automatically triggers cleanup if maximum storage quota is about to be hit (OFF or AUTO)
	)
GO


--=======================================================================>
-- RECOVER QUERY STORE
--=======================================================================>
-- First, clear the query store
ALTER DATABASE WideWorldImporters
SET QUERY_STORE CLEAR
GO

-- Second, set its operation mode back to READ_WRITE
ALTER DATABASE WideWorldImporters
SET QUERY_STORE (OPERATION_MODE = READ_WRITE);    
GO