-- 09. Advanced SQL for Data Analytics: CTEs and Temp Tables

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

-- 1.) CTEs and Temp Tables Introduction:

-- CTES
	-- Common Table Expression
	-- Not stored as an object/memory; last only during the execution of a query
	-- Similar to a Subquery, CTE can be self-referencing (a recursive CTE - referenced multiple times in the same query)
	-- Used for better readability and recursion

-- Temp Tables
	-- Special types of tables that store a temporary result set in memory 
	-- Reuse this temp table multiple times in a single session
	-- Great for storing complex queries that you want to reuse
	-- Great for reducing the complexity of queries, storing intermediate result sets, and improving performance

-- 2.) Using CTEs:

-- 2.1.1 CTE Example
WITH rfi_cte (rfi_id, rfi_subject, rfi_status, project_name, program_name) AS -- Adding column names directly from this line
(
SELECT
	r.id,
	r.subject,
	r.translated_status,
	p.name,
	p.program_name
FROM RFI r
JOIN Project p
	ON r.ProjectID = p.id
WHERE p.name LIKE 'SRJ%'
)
SELECT 
	project_name, 
	COUNT(rfi_id) AS count_of_id 
FROM rfi_cte
WHERE project_name <> 'SRJ Test Project 2 - Network Infrastructure'
GROUP BY project_name WITH ROLLUP

-- 2.1.2 CTE to Subquery

SELECT -- Exact same output of 2.1.1, but using subquery
	name,
	COUNT(id)
FROM 
(
SELECT
	r.id,
	r.subject,
	r.translated_status,
	p.name,
	p.program_name
FROM RFI r
JOIN Project p
	ON r.ProjectID = p.id
WHERE p.name LIKE 'SRJ%'
) AS rfi_subquery
WHERE name <> 'SRJ Test Project 2 - Network Infrastructure'
GROUP BY name WITH ROLLUP

-- 2.2 Multiple CTEs in one query execution

WITH srj_cte AS 
(
SELECT
	r.id,
	r.subject,
	r.translated_status,
	p.name,
	p.program_name
FROM RFI r
JOIN Project p
	ON r.ProjectID = p.id
WHERE p.name LIKE 'SRJ%'
),
ucd_cte AS 
(
SELECT
	r.id,
	r.subject,
	r.translated_status,
	p.name,
	p.program_name
FROM RFI r
JOIN Project p
	ON r.ProjectID = p.id
WHERE 
	p.name LIKE 'UCDMC%'
)
SELECT * FROM srj_cte
UNION ALL
SELECT * FROM ucd_cte

-- 3.) Recursion in CTEs
	-- CTE refers to itself, creating a loop that continues until a certain condition is met
	-- Useful for dealing with hierarchical or tree-structured data

-- 3.1 Simple recursion example

WITH simple_recursion AS
(
SELECT 1 AS x -- Anchor member: starts with 1

UNION ALL

SELECT x + 1 -- Recursive member: add 1 to x until the condition is met
FROM simple_recursion
WHERE x < 10 -- Add 1 to x until x is no longer less than 10 (need this part to avoid infinite loop)
)
SELECT * from simple_recursion

-- 4.) Temp Table
	-- Create a temp table from scratch OR bring in data from pre-existing tables

-- Example:
CREATE TABLE #DataCleaningTable (
	unique_id INT IDENTITY(1,1) PRIMARY KEY, -- Defining column will start at 1 and increment by 1 for each row
	user_id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	phone_number VARCHAR(15),
	birth_date VARCHAR(15),
	address VARCHAR(50),
	item_name VARCHAR(50),
	quantity INT,
	unit_price_usd DECIMAL(10,2),
	total_cost_usd DECIMAL(10,2)
)

INSERT INTO #DataCleaningTable (user_id, first_name, last_name, phone_number, birth_date, address, item_name, quantity, unit_price_usd, total_cost_usd)
	VALUES
		(184876, 'David', 'Evans', '(858)740-4751', '4/28/1989', '1229 Main Street, Scranton, PA', 'Electrical Wiring', 200, 2, 400),
		(118873, 'Olivia', 'Brown',  '/415/-632-9184', '4/11/1965', '123 North Hill Drive, Dallas, TX', 'Insulation Material', 300, 5, 1500),
		(182112, 'John', 'Anderson',  '\312\809-4725', '12/7/1999', '432 Hilly Road, Austin, TX', 'Concrete Mix', 50, 75, 3750),
		(176200, 'Daniel', 'Thompson',  '702(481)2337', '1978/08/20', '101 Apline Avenue, New York, NY', 'Plumbing Pipes', 150,	10,	1500),
		(171262, 'Jessica', 'Miller',  '6467289902', '1987/5/30', '701 North Street, Sarasota, FL', 'Paint', 60, 30, 1800),
		(176200, 'Daniel', 'Thompson',  '702(481)2337', '1978/8/20', '101 Apline Avenue, New York, NY', 'Plumbing Pipes', 150,	10,	1500),
		(141209, 'Michael', 'Foster',  '805431-5678', '7/9/2006', '12 South Main Lane, San Francisco, CA', 'Bricks',	5000, 0.5, 2500),
		(176200, 'Daniel', 'Thompson',  '702(481)2337', '1978/8/20', '101 Apline Avenue, New York, NY', 'Plumbing Pipes', 150,	10,	1500),
		(182112, 'John', 'Anderson',  '\312\809-4725', '12/7/1999', '432 Hilly Road, Austin, TX', 'Concrete Mix', 50, 75, 3750)

SELECT * FROM #DataCleaningTable

-- 5.) Temp Tables vs. CTEs

-- Temporary Tables
	-- Scope: Available for the session; can be reused in multiple queries
	-- Performance: Can be indexed and have statistics—better for large datasets
	-- Use: Ideal for reusing results across queries or working with large data

-- Common Table Expressions (CTEs)
	-- Scope: Limited to a single query.
	-- Performance: No indexing or statistics—may be slower for large datasets
	-- Use: Great for simplifying complex queries or using recursion (one-time simple use)

-- Which to Use?
	-- Temporary Tables: Best for large data, multiple query reuse, and performance tuning
	-- CTEs: Best for readability, breaking down complex queries, and recursion