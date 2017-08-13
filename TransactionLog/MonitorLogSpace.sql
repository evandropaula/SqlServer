USE master
GO


--=======================================================================>
-- DBCC SQLPERF (LOGSPACE)
--=======================================================================>
--	Displays transaction log space information for all database in the server
--	VIEW SERVER STATE permission is required to execute this command
DBCC SQLPERF (LOGSPACE)



--=======================================================================>
-- sys.database_files
--=======================================================================>
-- The following query provides more detailed information about the transaction log file(s)
-- Requires membership in the public role
-- size = Current size of the file, in 8-KB pages
-- LSN = Log Sequence Number, which stamped on each log record by SQL Server
SELECT
	*,
	size * 8 / 1024. AS SizeInMB, -- MB = size * 8KB pages / 1024.
	size * 8 / 1024. / 1024. AS SizeInGB,
	size * 8 / 1024. / 1024. / 1024. AS SizeInTB,
	size * 8 / 1024 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int) * 8 / 1024. AS UnusedSpaceInMB,
	size * 8 / 1024. / 1024. - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int) * 8 / 1024. / 1024. AS UnusedSpaceInGB,
	size * 8 / 1024. / 1024. / 1024. - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int) * 8 / 1024. / 1024. / 1024. AS UnusedSpaceInTB
FROM
	sys.database_files
WHERE
	type = 1
ORDER BY
	file_id