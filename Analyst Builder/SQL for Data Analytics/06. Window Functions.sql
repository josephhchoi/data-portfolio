-- 06. SQL for Data Analytics: Window Functions

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

-- Windows Functions Introduction:
	-- Performs a calculation across a set of rows that are related to the current row
	-- Does not cause rows to group into a single output row
	-- Functions are applied to each row individually
	-- Result is diplayed in a separate column

-- Over Clause & Partition By:

SELECT
	id,
	name,
	project_number,
	program_name,
	project_region,
	estimated_value,
	MAX(estimated_value) OVER() AS max_estimated_value -- Querying the max estimated over entire data
FROM Project
WHERE
	program_name IN ('San Juan Unified School District', 'UC Davis Medical Center')
ORDER BY program_name

SELECT
	id,
	name,
	project_number,
	program_name,
	project_region,
	estimated_value,
	MAX(estimated_value) OVER(PARTITION BY program_name) AS max_estimated_value -- Querying the max estimated partition by program name
FROM Project
WHERE
	program_name IN ('San Juan Unified School District', 'UC Davis Medical Center', 'La Mesa Spring Valley School District')
ORDER BY program_name

-- Row Number: 

SELECT
	id,
	name,
	project_number,
	program_name,
	project_region,
	estimated_value,
	row_number() OVER(ORDER BY(id)) AS row_num_1, -- V1: Querying row numbers for entire dataset
	row_number() OVER(ORDER BY(SELECT NULL)) AS row_num_2, -- V2: Querying row numbers for entire dataset
	row_number() OVER(PARTITION BY(program_name) ORDER BY(estimated_value)) AS row_num_3 -- Querying row numbers partitioned by program name and ordered by estimated value
FROM Project
WHERE
	program_name IN ('San Juan Unified School District', 'UC Davis Medical Center', 'La Mesa Spring Valley School District')


SELECT * -- row_number() over(partition() order by()) use case: Give me the top valued projects for each program using row_num_3
FROM -- Using subquery in the FROM statement
(
	SELECT
		id,
		name,
		project_number,
		program_name,
		project_region,
		row_number() OVER(PARTITION BY program_name ORDER BY estimated_value DESC) AS row_num_3 -- V3: Querying row numbers partitioned by program name and ordered by estimated value
	FROM Project
	WHERE
		program_name IN ('San Juan Unified School District', 'UC Davis Medical Center', 'La Mesa Spring Valley School District')
) AS row_table
WHERE row_num_3 < 3

-- Rank & Dense Rank:
	-- Rank:
		-- Assigns a rank to each row, but skips ranks when there are ties.
		-- Example: If two rows are tied for rank 1, the next row will get rank 3 (rank 2 is skipped).
		-- 1, 2, 2, 4
	-- Dense Rank:
		-- Assigns a rank to each row, but does not skip ranks when there are ties.
		-- Example: If two rows are tied for rank 1, the next row will get rank 2 (no ranks are skipped).
		-- 1, 2, 2, 3

SELECT
	id,
	name,
	project_number,
	program_name,
	project_region,
	estimated_value,
	RANK() OVER(PARTITION BY program_name ORDER BY estimated_value DESC) AS rank,
	DENSE_RANK() OVER(PARTITION BY program_name ORDER BY estimated_value DESC) AS dense_rank
FROM Project
WHERE
	program_name IN ('San Juan Unified School District', 'UC Davis Medical Center', 'La Mesa Spring Valley School District')

-- Lag and Lead:
	-- LAG(): Retrieves the value from the previous row within a result set.
	-- LEAD(): Retrieves the value from the next row within a result set.
	-- Difference: LAG() looks backwards to prior rows, while LEAD() looks forwards to subsequent rows.

SELECT -- Run query to understand difference
	id,
	name,
	project_number,
	program_name,
	project_region,
	ROW_NUMBER() OVER(PARTITION BY program_name ORDER BY estimated_value DESC) AS row_num,
	estimated_value,
	LAG(estimated_value) OVER(PARTITION BY program_name ORDER BY estimated_value DESC) AS lag, -- lag
	LEAD(estimated_value) OVER(PARTITION BY program_name ORDER BY estimated_value DESC) AS lead -- lead
FROM Project
WHERE
	program_name IN ('San Juan Unified School District', 'UC Davis Medical Center', 'La Mesa Spring Valley School District')