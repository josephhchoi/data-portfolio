-- 02. SQL for Data Analytics: Data Types + Functions

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

-- Data Types Introduction: Strings, numeric, Date/Time, Boolean

-- Numeric Functions:
SELECT 
	estimated_value,
	ROUND(estimated_value,1) AS estimatedvalue_rounded, -- Rounding
	CEILING(estimated_value) AS estimatedvalue_ceiling, -- Ceiling (Round up to the nearest whole number)
	Floor(estimated_value) AS estimatedvalue_floor, -- Floor (Round down to the nearest whole number)
	ABS(estimated_value) AS estimatedvalue_Abs, -- Absolute
	-(estimated_value) AS estimatedvalue_reverse -- Reversing the sign
FROM Project
WHERE estimated_value = 292929.28

-- String Functions:
SELECT
	name,
	LEN(name) AS length, -- Length of a string
	UPPER(name) AS name_upper, -- Uppercased
	LOWER(name) AS name_lower, -- Lowercased
	LEFT(name, 4), -- Extracting left text from a specified length
	RIGHT(name, 4), -- Extracting right text from a specified length
	SUBSTRING(name, 3, 3), -- syntax: string, start_position, length
	REPLACE(actual_start_date, '-', '') -- syntax: string, old string, new string)
FROM Project
ORDER BY LEN(name) DESC

SELECT 
	name, -- CHARINDEX: Locating the position of a substring in a string
	CHARINDEX(' ', name) -- Finding location (length) of where the ' ' is in 'name'
FROM Project 

-- Date and Date Format Functions:
SELECT
	estimated_start_date,
	GETDATE() AS CurrentDateTime, -- Returns current date and time
	SYSDATETIME() AS CurrentDateTimeV2, -- Returns current date and time with more precision (fractional seconds)
	CAST(GETDATE() AS DATE) AS CurrentDate,-- Returns only the date
	YEAR(GETDATE()) AS CurrentYear, 
	MONTH(GETDATE()) AS CurrentMonth,
	DAY(GETDATE()) AS CurrentDay,
	LEFT(DATENAME(WEEKDAY, GETDATE()),3) AS WeekdayName, -- Retrieving Weekday name using DATENAME()
	LEFT(DATENAME(MONTH, GETDATE()),3) AS MonthName, -- Retrieving Month name using DATENAME()
	FORMAT(GETDATE(), '%M-%d-%y'), -- Date Format Change
	FORMAT(GETDATE(), 'MMMM')
FROM Project

-- Case Statement Function: 
SELECT * FROM DirectCost WHERE ProjectID = '562949954591535'
SELECT * FROM DirectCostLineItem WHERE ProjectID = '562949954591535'

SELECT
	amount,
	CASE 
		WHEN amount >= 1000 THEN 'high' 
		WHEN amount BETWEEN 500 AND 1000 THEN 'medium' -- For BETWEEN/AND, have to make sure the numbers are 'LOW' AND 'HIGH'
		ELSE 'low' END AS category
FROM DirectCost 
WHERE ProjectID = '562949954591535'
