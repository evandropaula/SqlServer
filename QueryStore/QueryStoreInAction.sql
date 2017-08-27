USE WideWorldImporters
GO

--=======================================================================>
-- CHECK IF QUERY STORE IS ENABLED
--=======================================================================>
DECLARE @isQueryStoreEnabled  BIT

SELECT
	@isQueryStoreEnabled = is_query_store_on
FROM
	sys.databases
WHERE
	database_id = DB_ID()


IF (@isQueryStoreEnabled = 1)
BEGIN
	PRINT 'Query store is disabled for database ''' + DB_NAME() + ''''
	RETURN
END
GO


--=======================================================================>
-- CREATE STORED PROCEDURE FOR TESTING
--=======================================================================>
IF OBJECT_ID('dbo.sp_GetOrdersByCustomerId') IS NOT NULL
BEGIN
	PRINT 'Droppping stored procedure dbo.sp_GetOrdersByCustomerId...'
	DROP PROCEDURE dbo.sp_GetOrdersByCustomerId
END
GO

PRINT 'Creating stored procedure dbo.sp_GetOrdersByCustomerId...'
GO
CREATE PROCEDURE dbo.sp_GetOrdersByCustomerId
	@CustomerId BIGINT
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT
		*
	FROM
		Sales.Orders
	WHERE
		CustomerID = @CustomerId
END


--=======================================================================>
-- TEST
--=======================================================================>
-- First, let's clear the Query Store
ALTER DATABASE CURRENT SET QUERY_STORE CLEAR ALL
GO

-- Execute stored procedure for two different customers
EXEC sp_GetOrdersByCustomerId 90
GO

-- The following command will clear the procedure cache, causing a new plan to be created once sp_GetOrdersByCustomerId is executed again below
DBCC FREEPROCCACHE
GO

EXEC sp_GetOrdersByCustomerId 1060
GO

-- Gather the Query ID for the stored procedure just executed (e.g. 4) 
SELECT
    QS.query_id,
	QT.query_text_id,
	QT.query_sql_text	
FROM
	sys.query_store_query_text AS QT
JOIN
	sys.query_store_query AS QS ON QT.query_text_id = QS.query_text_id


-- Check query history, runtime statistics (e.g. duration, execution count, CPU, memory and IO) and execution plans
SELECT
    Q.query_id,
	QT.query_text_id,
	QT.query_sql_text,
	P.plan_id,
	RS.avg_logical_io_reads,
	RS.runtime_stats_id,
	RS.avg_duration, -- Duration
	RS.last_duration,
	RS.min_duration,
	RS.max_duration,
	RS.avg_rowcount, -- Execution Count
	RS.count_executions,
	RS.avg_cpu_time, -- CPU
	RS.last_cpu_time,
	RS.min_cpu_time,
	RS.max_cpu_time,
	RS.avg_logical_io_reads, -- Logical IO reads
	RS.last_logical_io_reads,
	RS.min_logical_io_reads,
	RS.max_logical_io_reads,
	RS.avg_physical_io_reads, -- Physical IO reads
	RS.last_physical_io_reads,
	RS.min_physical_io_reads,
	RS.max_physical_io_reads,
    RSI.start_time,
	RSI.end_time
FROM
	sys.query_store_query_text AS QT
JOIN
	sys.query_store_query AS Q ON QT.query_text_id = Q.query_text_id
JOIN
	sys.query_store_plan AS P ON Q.query_id = P.query_id
JOIN
	sys.query_store_runtime_stats AS RS ON P.plan_id = RS.plan_id
JOIN
	sys.query_store_runtime_stats_interval AS RSI ON RSI.runtime_stats_interval_id = RS.runtime_stats_interval_id
WHERE
	Q.query_id = 4 -- Attention: change this value based on the data collected in the previous query
GO


--=======================================================================>
-- REMOVE STORED PROCEDURE FROM DATABASE
--=======================================================================>
IF OBJECT_ID('dbo.sp_GetOrdersByCustomerId') IS NOT NULL
BEGIN
	PRINT 'Droppping stored procedure dbo.sp_GetOrdersByCustomerId...'
	DROP PROCEDURE dbo.sp_GetOrdersByCustomerId
END
ELSE
BEGIN
	PRINT 'Stored procedure dbo.sp_GetOrdersByCustomerId was not found...'
END
GO