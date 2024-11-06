-- 10. Advanced SQL for Data Analytics: Stored Procedures, Triggers and Events, Indexing for Performance

-- 1. Stored Procedures:
	-- Saved SQL script that can be executed repeatedly
	-- Include SQL statements like SELECT, INSERT, UPDATE, and DELETE, along with logic and control-flow statements

-- 1.1.1 Benefits:
	-- Reusability: Write once, run multiple times with different parameters
	-- Performance: Compiled and stored in the database, which means it can execute faster
	-- Security: Users can execute the procedure without knowing the underlying SQL, offering controlled access to data

-- 1.1.2 Syntax:
CREATE PROCEDURE procedure_name
    @param1 datatype, 
    @param2 datatype
AS
BEGIN
    SELECT * FROM table_name WHERE column = @param1;
END;

-- 1.1.3 Example:
CREATE PROCEDURE GetEmployeeDetails
    @EmployeeID INT
AS
BEGIN
    SELECT * FROM Employees WHERE ID = @EmployeeID;
END;

EXEC GetEmployeeDetails @EmployeeID = 101;

-- 2. Triggers and Events:

-- 2.1.1 Triggers:
	-- Automatic response to certain database events (like INSERT, UPDATE, or DELETE) on a table.
	-- Fires automatically when the specified event occurs.
	-- Useful for enforcing business rules, auditing changes, or cascading updates/deletes.

-- 2.1.2 Types:
	-- AFTER Trigger: Executes after an event like INSERT or UPDATE.
	-- INSTEAD OF Trigger: Executes in place of the triggering event.

-- 2.1.3 Syntax:
CREATE TRIGGER trigger_name
ON table_name
AFTER INSERT, UPDATE
AS
BEGIN
    PRINT 'An update or insert occurred.';
END;

-- 2.1.4 Example: 
CREATE TRIGGER trgAfterInsert
ON Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (Event, EventDate)
    VALUES ('New employee added', GETDATE());
END;

-- 2.2.1 Events
	-- Refer to actions or occurrences that can be tracked or responded to using Event Notifications, SQL Server Agent, or Extended Events.
	-- Useful for monitoring database activities, automating tasks, or notifying users when specific conditions are met.

-- 2.2.2 Event Notification
	-- Capture DDL (Data Definition Language) and DML (Data Manipulation Language) changes, such as CREATE, ALTER, DROP, INSERT, UPDATE, and DELETE.
	-- Do not directly execute code but send information about events to a Service Broker queue for further processing.
	-- Useful for auditing, tracking changes, or integrating with other systems that need to be informed about database changes.
	-- Do not block the original event from occurring.

-- 2.2.3 Syntax:

CREATE EVENT NOTIFICATION notification_name
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
TO SERVICE 'ServiceName', 'current database';
Example:

-- 2.2.4 Example: 
CREATE EVENT NOTIFICATION AuditDatabaseChanges
ON DATABASE
FOR CREATE_TABLE, DROP_TABLE
TO SERVICE 'AuditService', 'current database';

-- 3. Indexing for Performance

-- 3.1.1 Indexing Introduction
	-- Index is a database object that improves the speed of data retrieval operations on a table.
	-- Works similarly to an index in a book, allowing SQL Server to quickly locate the rows in a table.

-- 3.1.2 Why Use Indexes?
	-- Improves Query Performance: Indexes reduce the time it takes for SELECT queries to find data.
	-- Enhances Sorting and Searching: Helps with ORDER BY, JOIN, and WHERE clauses, making data access faster.

-- 3.1.3 Trade-offs:
	-- Write Penalty: INSERT, UPDATE, and DELETE operations may be slower since indexes need to be updated.
	-- Storage Space: Indexes consume extra storage space, especially for large tables.

-- 3.2.1 Types of Indexes:

-- Clustered Index:
	-- Sorts and stores the rows of the table physically.
	-- A table can have only one clustered index because it defines the physical order of the data.
	-- Example: Primary key columns often use a clustered index.

-- Non-Clustered Index:
	-- Creates a separate structure to store index data and points back to the actual table rows.
	-- A table can have multiple non-clustered indexes.
	-- Example: Useful for columns frequently used in WHERE clauses.

-- 3.2.2 Syntax:

-- Clustered Index
CREATE CLUSTERED INDEX idx_employee_id ON Employees (ID);

-- Non-Clustered Index
CREATE NONCLUSTERED INDEX idx_last_name ON Employees (LastName);

-- 3.3.1 Prefix Indexes
	-- Used on character columns, indexing only the beginning characters of a field.
	-- More common in other databases like MySQL but is also applicable conceptually in SQL Server when you want to improve performance by reducing the size of the index.

-- 3.3.2 Example:
	-- Consider indexing only the first 10 characters of a LastName field:
	-- Non-clustered Index on the first few characters
CREATE NONCLUSTERED INDEX idx_last_name_partial ON Employees (LEFT(LastName, 10));

-- 3.3.3 Use Case:
	-- When only a part of a column is sufficiently unique, like a prefix in text columns, which can reduce the index size and improve performance.

-- 3.4.1 Composite Indexes
	-- A composite index (multi-column index) is an index on two or more columns.
	-- Beneficial when queries often filter or sort based on multiple columns.

-- 3.4.2 Syntax
	-- Create a composite index on LastName and FirstName
	CREATE NONCLUSTERED INDEX idx_last_first_name ON Employees (LastName, FirstName);

-- 3.4.3 Order Matters:
	-- The order of columns in a composite index matters:
	-- The first column should be the one that is most frequently queried.
	-- SQL Server uses the leftmost column first when performing lookups.

-- 3.4.4 Use Case:
	-- Ideal when a query often filters by LastName and FirstName together:
	-- SELECT * FROM Employees WHERE LastName = 'Smith' AND FirstName = 'John';

-- 4. Understanding Indexes Better + Best Practices

-- 4.1.1 Understanding Indexes:
	-- Seek vs. Scan:
		-- Index Seek: SQL Server quickly finds data using an index, typically more efficient.
		-- Index Scan: SQL Server scans the entire index or table, which can be slower.
	-- Covering Index:
		-- A non-clustered index that includes all columns needed to satisfy a query, avoiding the need to access the base table.
	
-- 4.1.2 Best Practices:
	-- Index Columns used in WHERE, JOIN, and ORDER BY: Indexing these columns can greatly improve performance.
	-- Avoid Over-Indexing: Too many indexes can slow down data modifications like INSERT, UPDATE, and DELETE.
	-- Use INCLUDE: Add non-key columns to a non-clustered index using the INCLUDE statement to make it a covering index.
	-- Regularly Monitor and Rebuild Indexes: Use REBUILD and REORGANIZE to maintain index efficiency:
	ALTER INDEX idx_last_first_name ON Employees REBUILD;
	-- Choose the Right Index Type: Use clustered indexes for frequently queried unique columns (e.g., IDs) and non-clustered indexes for other important columns.
