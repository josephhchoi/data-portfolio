-- 11. Advanced SQL Tutorial: DECLARE

-- Tables:
SELECT * FROM Project
SELECT * FROM ProjectRole
SELECT * FROM ProjectTask
SELECT * FROM ProjectTool
SELECT * FROM ProjectUser
SELECT * FROM ProjectVendor

SELECT * FROM RFI
SELECT * FROM WbsCode
SELECT * FROM Submittal
SELECT * FROM WorkOrderContract
SELECT * FROM Correspondence

-- 1.) What is DECLARE?
	-- Initializes a variable with a specific data type.
	-- Allocates space for the variable and allows you to store and manipulate data during the execution of a script.

-- 1.1.1 Syntax
	DECLARE @variable_name datatype;

-- 1.1.2 Example
	-- Declaring an integer variable
	DECLARE @EmployeeCount INT;

	-- Setting a value to the variable
	SET @EmployeeCount = 100;

	-- Using the variable in a SELECT statement
	SELECT @EmployeeCount AS TotalEmployees;

-- 1.1.3 Use Cases
	-- Store Values for Reuse: Store values from a query that you might want to use multiple times within a script.
	-- Temporary Data Storage: Hold intermediate results before performing calculations or comparisons.
	-- Looping and Control Flow: Use variables with WHILE loops, IF statements, and CASE conditions.

-- 1.2.1 Example with Kitchell Data

SELECT DISTINCT project_region FROM Project

DECLARE @project_region VARCHAR(20)
SET @project_region = 'Texas/Central' 

SELECT
	@project_region AS project_region,
	CEILING(AVG(estimated_value)) AS avg_estimated_value
FROM Project
WHERE project_region = @project_region