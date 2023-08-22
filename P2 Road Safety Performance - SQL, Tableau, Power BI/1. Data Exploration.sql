----- Platform Used: SQL Server Management -----

----- DATA EXPLORATION ------

-- 1.) Time-based Analysis

	-- Monthly average # of injuries and accidents:

SELECT
    FORMAT(CONVERT(date, [Accident Date]), 'yyyy-MM') AS MonthYear,
    AVG(TRY_CAST(Number_of_Casualties AS FLOAT)) AS AvgInjuries,
	AVG(TRY_CAST(Number_of_Vehicles AS FLOAT)) AS AvgAccidents
FROM
    dbo.[Road Accident Data]
GROUP BY
    FORMAT(CONVERT(date, [Accident Date]), 'yyyy-MM')
ORDER BY
    AvgInjuries DESC,
	AvgAccidents DESC;

-- 2.) Geographical Analysis

	-- Region with highest averages:

SELECT
    [Local_Authority_(District)] AS Region,
    AVG(TRY_CAST(Number_of_Casualties AS FLOAT)) AS AvgInjuries,
	AVG(TRY_CAST(Number_of_Vehicles AS FLOAT)) AS AvgAccidents
FROM
    dbo.[Road Accident Data]
WHERE
    [Local_Authority_(District)] IS NOT NULL
GROUP BY
    [Local_Authority_(District)]
ORDER BY
    AvgInjuries DESC,
	AvgAccidents DESC;

-- 3.) Weather Conditions Analysis

	-- Weather category with highest averages:

SELECT
    Weather_Conditions,
    AVG(TRY_CAST(Number_of_Casualties AS FLOAT)) AS AvgInjuries,
	AVG(TRY_CAST(Number_of_Vehicles AS FLOAT)) AS AvgAccidents
FROM
    dbo.[Road Accident Data]
GROUP BY
    Weather_Conditions
ORDER BY
    AvgInjuries DESC,
	AvgAccidents DESC;

-- 4.) Day of the Week Analysis

	-- Calculating the total # of accidents by day of the week:

SELECT
    Day_of_Week,
    COUNT(*) AS Accident_Count
FROM
    dbo.[Road Accident Data]
GROUP BY
    Day_of_Week
ORDER BY
    CASE
        WHEN Day_of_Week = 'Sunday' THEN 1
        WHEN Day_of_Week = 'Monday' THEN 2
        WHEN Day_of_Week = 'Tuesday' THEN 3
        WHEN Day_of_Week = 'Wednesday' THEN 4
        WHEN Day_of_Week = 'Thursday' THEN 5
        WHEN Day_of_Week = 'Friday' THEN 6
        WHEN Day_of_Week = 'Saturday' THEN 7
        ELSE 8
    END;

-- 5.) Accident Severity Analysis

	-- Calculate the total number of accidents for each severity level

SELECT 
	Accident_Severity, COUNT(*) AS Accident_Count
FROM 
    dbo.[Road Accident Data]
GROUP BY 
	Accident_Severity;

	-- Find the percentage of accidents that resulted in fatal or serious injuries

SELECT 
	Accident_Severity,
	(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS Percentage
FROM 
    dbo.[Road Accident Data]
WHERE
	Accident_Severity IN ('fatal', 'serious')
GROUP BY 
	Accident_Severity;	

-- 6.) Road Surface Condition Analysis

	-- Calculating the most frequent conditon for fatal accidents

WITH FatalAccidents AS (
    SELECT *
    FROM dbo.[Road Accident Data]
    WHERE Accident_Severity = 'Fatal'
)

SELECT
    Road_Surface_Conditions,
    COUNT(*) AS Frequency
FROM
    FatalAccidents
GROUP BY
    Road_Surface_Conditions
ORDER BY
    Frequency DESC;

	-- Analzying accident severity by road surface condition

WITH AccidentStats AS (
    SELECT
        Road_Surface_Conditions,
        Accident_Severity,
        COUNT(*) AS AccidentCount
    FROM
        dbo.[Road Accident Data]
    GROUP BY
        Road_Surface_Conditions, Accident_Severity
)

SELECT
    Road_Surface_Conditions,
    SUM(CASE WHEN Accident_Severity = 'Fatal' THEN AccidentCount ELSE 0 END) AS FatalCount,
    SUM(CASE WHEN Accident_Severity = 'Serious' THEN AccidentCount ELSE 0 END) AS SeriousCount,
    SUM(AccidentCount) AS TotalCount
FROM
    AccidentStats
GROUP BY
    Road_Surface_Conditions
ORDER BY
    TotalCount DESC;

-- 7.) Vehicle Type Analysis

	-- Finding the vehicle types involved in serious accidents

WITH SeriousAccidents AS (
    SELECT *
    FROM dbo.[Road Accident Data]
    WHERE Accident_Severity = 'Serious'
)

SELECT DISTINCT
    Vehicle_Type
FROM
    SeriousAccidents;
