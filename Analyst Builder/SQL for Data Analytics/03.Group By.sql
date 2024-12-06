-- 03. SQL for Data Analytics: Group By

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

-- Group By:
SELECT
	vendor,
	SUM(amount) AS total_sum,
	AVG(amount) AS average,
	COUNT(vendor) AS total_count, -- Count only counts non-null values
	COUNT(*) AS total_row -- If I want to count null values, count the rows
FROM DirectCost 
WHERE ProjectID = '562949954591535'
GROUP BY vendor
ORDER BY total_sum DESC

-- Having:
SELECT
	vendor,
	SUM(amount) AS total_sum
FROM DirectCost 
WHERE ProjectID = '562949954591535'
GROUP BY vendor
HAVING SUM(amount) > 5000 -- Filter group/aggregation
ORDER BY total_sum DESC

-- Rollup:
SELECT
	vendor,
	SUM(amount) AS total_sum
FROM DirectCost 
WHERE ProjectID = '562949954591535'
GROUP BY vendor WITH ROLLUP

SELECT
	vendor,
	SUM(amount) AS total_sum
FROM DirectCost 
WHERE ProjectID = '562949954591535'
GROUP BY vendor WITH ROLLUP -- Total doesn't factor in HAVING
HAVING SUM(amount) > 2000