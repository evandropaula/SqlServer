USE master
GO

--=======================================================================>
-- DEADLOCK_PRIORITY
--=======================================================================>
-- Deadlock Monitor is a system task that wakes up EVERY 5 SECONDS, which can go down in case deadlocks are frequently detected 
-- Deadlock victim is determined based on session that is LESS EXPENSIVE to roll back
-- In case the DEADLOCK_PRIORITY is set, the session with the LOWEST DEADLOCK PRIORITY is chosen as the deadlock victim
-- Membership to PUBLIC ROLE is required
SET DEADLOCK_PRIORITY NORMAL  
-- OR

-- The following approach allows greater granularity when configuring the deadlock priority
-- Numbers are from -10 to 10
SET DEADLOCK_PRIORITY -2
GO


--=======================================================================>
-- TRACE FLAGs FOR TROUBLESHOOTING DEADLOCKS
--=======================================================================>
-- Sysadmin permission is required to execute DBCC TRACEON and TRACESTATUS
-- CAUTION: Flags enabled through DBCC TRACEON will be lost when SQL Server restarts.
--			Therefore, it is also recommended to configure them on the SQL Server startup using SQL Configuration Manager,
--			which default location is at C:\Windows\SysWOW64\SQLServerManager<version>.msc (e.g. SQLServerManager14.msc),
--			under SQL Server Services -> SQL Server -> Properties -> Startup Parameters
--
-- https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql

-- Check current trace flag current value
DBCC TRACESTATUS(1204, 1222)

-- Switches trace flags to ON GLOBALLY due to -1 parameter
DBCC TRACEON(1222, 1204, -1)

DBCC TRACESTATUS(1204, 1222)
GO