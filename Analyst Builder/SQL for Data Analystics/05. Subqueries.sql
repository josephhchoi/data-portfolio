-- 05. SQL for Data Analytics: Subqueries

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
SELECT * FROM DirectCostLineItem

-- Subquery Introduction: 
	-- SELECT statement that is nested within another query (subquery/outer query)
	-- When to use JOIN: Combine data from multiple tables (efficient with larget datasets)
	-- When to use SUBQUERY: Use for non-correlated subqueries scenarios and not correlated subqueries scenario (when data is smaller)
	-- Rule of thumb: JOINs will be faster than Subquery most of the time (most of the time at work, we use big data)

-- Subquery Basics: 

SELECT 
	ProjectID,
	id AS submittal_id,
	specification_section_label
FROM Submittal
WHERE ProjectID IN -- Example 1: Using Subquery in a WHERE clause
( 
	SELECT id
	FROM Project
	WHERE 
		name LIKE 'SRJ%' AND
		project_number <> 'Test Project' -- Subquery in a WHERE clause have 1 column
)

SELECT
	ProjectID,
	id AS submittal_id,
	specification_section_label,
	received_date,
	distributed_at,
	DATEDIFF(DAY, received_date, distributed_at) AS turnaround
FROM Submittal
WHERE DATEDIFF(DAY, received_date, distributed_at) > -- Example 2: Using Subquery in a WHERE clause
(
	SELECT AVG(CAST(DATEDIFF(DAY, received_date, distributed_at) AS FLOAT)) -- AVG cannot be applied to output of DATEDIFF(). Only INT
	FROM Submittal
)
ORDER BY turnaround DESC

-- ALL and ANY Operators:
	-- They are used with subqueries
	-- ALL: Conditions will be satisfied only if the operation is true for ALL values in a range within that subquery
	-- ANY: Conditions will be satisfied only if the operation is true for ANY values in a range within that subquery

SELECT -- Outer Query: Returns rows where the turnaround is **equal to** every value returned by the subquery
	ProjectID,
	id AS submittal_id,
	specification_section_label,
	received_date,
	distributed_at,
	DATEDIFF(DAY, received_date, distributed_at) AS turnaround
FROM Submittal
WHERE DATEDIFF(DAY, received_date, distributed_at) = ALL -- Using ALL: Value from the outer query must be equal to every value in the subquery
(
	SELECT DATEDIFF(DAY, received_date, distributed_at) AS turnaruond
	FROM Submittal
	WHERE DATEDIFF(DAY, received_date, distributed_at) BETWEEN 100 AND 150
)
ORDER BY turnaround DESC -- If no single value from the Outer Query satisfies the "equal to all values" condition, the result will be blank.

SELECT -- Outer Query: Returns rows where the turnaround matches at least one value from the subquery
	ProjectID,
	id AS submittal_id,
	specification_section_label,
	received_date,
	distributed_at,
	DATEDIFF(DAY, received_date, distributed_at) AS turnaround
FROM Submittal
WHERE DATEDIFF(DAY, received_date, distributed_at) = ANY -- Using ANY: The condition must be true for at least one value from the subquery
(
	SELECT DATEDIFF(DAY, received_date, distributed_at) AS turnaruond
	FROM Submittal
	WHERE DATEDIFF(DAY, received_date, distributed_at) BETWEEN 100 AND 150
)
ORDER BY turnaround DESC -- If at least one value from the subquery matches the outer query's turnaround, the row is returned.

SELECT -- Outer Query: Returns rows where the turnaround is **greater than** every value returned by the subquery
	ProjectID,
	id AS submittal_id,
	specification_section_label,
	received_date,
	distributed_at,
	DATEDIFF(DAY, received_date, distributed_at) AS turnaround
FROM Submittal
WHERE DATEDIFF(DAY, received_date, distributed_at) > ALL -- Using ALL: Value from the outer query must be greater than every value in the subquery
(
	SELECT DATEDIFF(DAY, received_date, distributed_at) AS turnaruond
	FROM Submittal
	WHERE DATEDIFF(DAY, received_date, distributed_at) BETWEEN 100 AND 150
)
ORDER BY turnaround DESC -- Returns value that is greater than MAX(Subquery)

SELECT -- Outer Query: Returns rows where the turnaround is **greater than** every value returned by the subquery
	ProjectID,
	id AS submittal_id,
	specification_section_label,
	received_date,
	distributed_at,
	DATEDIFF(DAY, received_date, distributed_at) AS turnaround
FROM Submittal
WHERE DATEDIFF(DAY, received_date, distributed_at) > ANY -- Using ANY: Value from the outer query must be greater than any value in the subquery
(
	SELECT DATEDIFF(DAY, received_date, distributed_at) AS turnaruond
	FROM Submittal
	WHERE DATEDIFF(DAY, received_date, distributed_at) BETWEEN 100 AND 150
)
ORDER BY turnaround DESC -- Returns value that is greater than MIN(Subquery)

-- Exists: 
	-- IN operator: Runs through and count every single row
	-- EXISTS operator: Runs through rows and the first time it hits a true, it'll evaluate a true and it'll stop all processes
	-- Checks to see if a value exists within the subquery
		-- If true, it will give an output
		-- If falues, it will not give an output
	-- Use EXISTS for performance (faster than IN)

SELECT 
	ProjectID,
	id AS submittal_id,
	specification_section_label
FROM Submittal s
WHERE EXISTS -- Using EXISTS to check if SRJ projects have test projects
( 
	SELECT id
	FROM Project p
	WHERE 
		name LIKE 'SRJ%' AND
		project_number = 'Test Project'
)

-- Subqueries in SELECT and FROM:

SELECT
	ProjectID,
	id AS submittal_id,
	specification_section_label,
	received_date,
	distributed_at,
	DATEDIFF(DAY, received_date, distributed_at) AS turnaround,
	(SELECT AVG(CAST(DATEDIFF(DAY, received_date, distributed_at) AS FLOAT)) FROM Submittal) AS avg_turnaround -- Using subqueries in SELECT statement to bring in AVG
FROM Submittal


SELECT -- Subquery in FROM statement
	ProjectID,
	avg_turnaround,
	avg_turnaround - 1 AS avg_turnaround_v2
FROM 
(
	SELECT
		ProjectID,
		id AS submittal_id,
		specification_section_label,
		received_date,
		distributed_at,
		DATEDIFF(DAY, received_date, distributed_at) AS turnaround,
		(SELECT AVG(CAST(DATEDIFF(DAY, received_date, distributed_at) AS FLOAT)) FROM Submittal) AS avg_turnaround
	FROM Submittal
) AS DatedDiff -- Using subqueries in FROM statement (need name for FROM subquery)