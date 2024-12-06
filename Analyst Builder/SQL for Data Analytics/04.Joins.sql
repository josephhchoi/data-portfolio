-- 04. SQL for Data Analytics: Joins

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

-- Cartesian Join: Every row from the first table is combined with every row from the second table (Returns all possible combinations)

-- Joins Introduction:
SELECT woc.id AS woc_id, woc.number, woc.grand_total, woc.ProjectID, p.id, p.name, p.project_number
FROM WorkOrderContract woc
INNER JOIN Project p ON woc.ProjectID = p.id -- Inner Join
WHERE woc.ProjectID = '562949954591535'

SELECT woc.id AS woc_id, woc.number, woc.grand_total, woc.ProjectID, p.id, p.name, p.project_number
FROM WorkOrderContract woc
LEFT JOIN Project p ON woc.ProjectID = p.id -- Left Join
WHERE woc.ProjectID = '562949954591535'

SELECT woc.id AS woc_id, woc.number, woc.grand_total, woc.ProjectID, p.id, p.name, p.project_number
FROM WorkOrderContract woc
RIGHT JOIN Project p ON woc.ProjectID = p.id -- Right Join
WHERE woc.ProjectID = '562949954591535'

SELECT woc.id AS woc_id, woc.number, woc.grand_total, woc.ProjectID, p.id, p.name, p.project_number
FROM WorkOrderContract woc
FULL JOIN Project p ON woc.ProjectID = p.id -- Full Join
WHERE woc.ProjectID = '562949954591535'

-- Joining Multiple Tables:
SELECT
	p.name,
	p.project_bid_type_name,
	woc.id AS woc_id,
	woc.grand_total AS woc_amount,
	dc.id AS dc_id,
	dc.amount AS dc_amount
FROM Project p
JOIN WorkOrderContract woc -- Showing casing multiple JOINs in one query
	ON p.id = woc.ProjectID
JOIN DirectCost dc
	ON p.id = dc.ProjectID
WHERE p.id = '562949954591535'

-- Joining on Multiple Conditions:
SELECT * -- Proof of concept (query won't return anything)
FROM Project p
JOIN Submittal s
	ON p.id = s.ProjectID AND -- Showing casing multiple ON conditions in one query
       p.id = s.specification_section_id AND
	   p.created_at = s.created_at

-- Self Join
SELECT 
	p1.id AS id_1,
	p1.project_number,
	p2.id AS id_2,
	p2.project_number AS parent_project_number -- Showcasing self join and how it is applicable
FROM Project p1 
JOIN Project p2
	ON p1.id = p2.id + 1 -- If there is a relationship that you can exploit in the same table, take advantage of ON (employee to boss, project to parent project relatioship)

-- Cross Join
SELECT *
FROM Project
CROSS JOIN Submittal -- Same as Cartesian Join
					 -- Cartesian Join: Every row from the first table is combined with every row from the second table (Returns all possible combinations)
