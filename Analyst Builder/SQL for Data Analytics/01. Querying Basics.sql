-- 01. SQL for Data Analytics: Querying Basics

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

-- Execution Order: FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY, LIMIT

-- Basics of Querying:
USE Procore -- Choosing database

SELECT id, name, project_number 
FROM Project 
WHERE project_number = '6601'

-- Select Statement:
SELECT COUNT(*) AS 'RowCount' FROM Project -- Count the total number of rows in a table

SELECT 
	estimated_value,
	estimated_value + 100 AS estimated_value_add100 -- Calculation
FROM Project

SELECT DISTINCT name, project_number FROM Project -- Using Distinct

-- Where Clause
SELECT 
	name,
	program_name,
	estimated_start_date
FROM Project
WHERE estimated_start_date >= '2024-01-01' -- Querying rows that are after 1/1/2024
ORDER BY estimated_start_date

-- Comparison Operators (=, <>, !=, >, <, >=, <=)

-- Logical Operators (AND, OR, NOT)
SELECT 
	name, project_number, project_stage_name, project_region
FROM Project
WHERE
	project_stage_name = 'Construction' AND -- All conditions must be valid 
	project_region = 'Bay Area'

SELECT 
	name, project_number, project_stage_name, project_region
FROM Project
WHERE
	project_stage_name = 'Construction' OR -- Only 1 conditions need to be valid
	project_region = 'Bay Area'

SELECT 
	name, project_number, project_stage_name, project_region
FROM Project
WHERE
	project_stage_name IS NOT NULL AND -- Is not null
	project_region = 'Bay Area'

SELECT 
	name, project_number, project_stage_name, project_region
FROM Project
WHERE
	project_stage_name IS NULL AND -- Is null
	project_region = 'Bay Area'
	
SELECT 
	name, project_number, project_stage_name, project_region
FROM Project
WHERE
	(project_stage_name = 'Construction' OR project_stage_name = 'Design') AND -- Order of operation example: OR first THEN AND
	project_region = 'Bay Area'

SELECT 
	TOP 5 name, project_number, project_stage_name, project_region -- Don't use LIMIT. Use TOP
FROM Project
WHERE 
	NOT project_stage_name = 'Construction' AND -- Using NOT and AND together
	NOT project_stage_name = 'Design' AND
	NOT project_stage_name = 'Closeout'

-- IN Operator (Multiple OR statements)
SELECT
	name,
	project_stage_name,
	project_region
FROM Project
WHERE project_region IN ('Bay Area', 'Northern California') -- IN

SELECT
	name,
	project_stage_name,
	project_region
FROM Project
WHERE project_region NOT IN ('Bay Area', 'Northern California') -- NOT IN

SELECT
	name,
	project_stage_name,
	project_region
FROM Project
WHERE 
	project_region IN ('Bay Area', 'Northern California') AND -- Using IN and AND
	project_stage_name IN ('Construction', 'Design')

-- Between Operator
SELECT
	name,
	project_stage_name,
	project_region,
	estimated_start_date
FROM Project
WHERE 
	estimated_start_date BETWEEN '2023-01-01' AND '2023-12-31' AND -- Using BETWEEN and AND/IN
	project_region IN ('Bay Area', 'Northern California')
ORDER BY estimated_start_date

-- Like Operator
	-- "%": Wilcard(zero, one, or multiple characters)
	-- "_": Single character

SELECT name
FROM Project
WHERE name LIKE 'SRJ%' -- Beginning

SELECT name
FROM Project
WHERE name LIKE '%Upgrades' -- End

SELECT name
FROM Project
WHERE name LIKE '%SRJ%' -- Anywhere

SELECT name
FROM Project
WHERE name LIKE 'SRJ______' -- Dictating number of characters after SRJ
