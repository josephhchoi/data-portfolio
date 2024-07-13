-- Platform Used: SSMS --

-- 1. SETUP:

-- Specified database
USE jhc;
GO

-- Verified that all tables were imported successfully
SELECT * FROM Absenteeism_at_work
SELECT * FROM Reasons
SELECT * FROM Compensation

-- 2. ANALYSIS:

-- Identified # of employees qualified for the healthy bonus program
	-- # of Healthy Employees: 111
	-- # of TTL Employees: 740
	-- Healthy Employee Ratio: 15%

SELECT 
	COUNT(*) AS CountOfHealthyEmployees,
	(SELECT COUNT(*) FROM Absenteeism_at_work) AS CountofAllEmployees,
	CAST(COUNT(*) AS FLOAT)/(SELECT COUNT(*) FROM Absenteeism_at_work) AS HealthyToTotalRatio
FROM Absenteeism_at_work
WHERE Social_drinker = 0 -- Not a social drinker
	AND Social_smoker = 0 -- Not a social smoker
	AND Body_mass_index < 25 -- BMI less than 25
	AND Absenteeism_time_in_hours < (SELECT AVG(Absenteeism_time_in_hours) FROM Absenteeism_at_work); -- Absenteeism time below the average

-- Calculated the annual wage increase for non-smokers within the insurance budget
	-- Insurance Budget: $983,221
	-- Working Days: 5 | Working Hours: 8 | Working Weeks: 52 | Hours per Year: 2,080
	-- # of Non-Smokers: 686
	-- Increase per Hour: $0.69
	-- Annual Wage Increase: $1,435 

WITH NonSmokers AS (
	SELECT 
		COUNT(*) AS CountOfNonSmokers,
		983221 AS Budget
	FROM Absenteeism_at_work
	WHERE Social_smoker = 0
)
SELECT
	ns.CountOfNonSmokers,
	5*8*52 AS HoursPerYear,
	5*8*52*ns.CountOfNonSmokers AS NonSmokersHoursPerYear,
	ROUND(CAST(ns.Budget AS FLOAT) / CAST(5*8*52*ns.CountOfNonSmokers AS FLOAT),2) AS IncreasePerHour,
	5*8*52*(SELECT ROUND(CAST(ns.Budget AS FLOAT) / CAST(5*8*52*ns.CountOfNonSmokers AS FLOAT),2) FROM NonSmokers) AS AnnualWageIncrease
FROM NonSmokers ns

-- 3. QUERY FOR POWER BI PLUG-IN:

-- Combined tables via JOIN

SELECT * FROM Absenteeism_at_work aaw
LEFT JOIN Reasons r
	ON aaw.Reason_for_absence = r.Number
LEFT JOIN Compensation c
	ON aaw.ID = c.ID;

-- Optimized query for data retrieval and analysis

SELECT
	aaw.ID,
	r.Reason,
	Month_of_absence,
	CASE 
		WHEN Month_of_absence IN (12,1,2) THEN 'Winter'
		WHEN Month_of_absence IN (3,4,5) THEN 'Spring'
		WHEN Month_of_absence IN (6,7,8) THEN 'Summer'
		WHEN Month_of_absence IN (9,10,11) THEN 'Fall'
		ELSE 'Unknown' END AS Season_Names,
	Body_mass_index,
	CASE
		WHEN Body_mass_index < 18.5 THEN 'Underweight'
		WHEN Body_mass_index BETWEEN 18.5 AND 25 THEN 'Healthy Weight'
		WHEN Body_mass_index BETWEEN 25 AND 30 THEN 'Overweight'
		WHEN Body_mass_index < 30 THEN 'Obese'
		ELSE 'Unknown' END AS BMI_Category,
	Day_of_the_week,
	Transportation_expense,
	Education,
	Son,
	Social_drinker,
	Social_smoker,
	Pet,
	Disciplinary_failure,
	Age,
	Work_load_Average_day,
	Absenteeism_time_in_hours,
	comp_hr
FROM Absenteeism_at_work aaw
LEFT JOIN Reasons r
	ON aaw.Reason_for_absence = r.Number
LEFT JOIN Compensation c
	ON aaw.ID = c.ID;

-- 4. DATA MANIPULATION

-- Updating misspelled value in the 'Reasons' table
UPDATE Reasons
SET Reason = 'Unknown'
WHERE 
	Number = 0 AND 
	Reason = 'Unkown'

-- Capitalized the first letter of each word in the 'Reason' column (Proper Case)
	-- Built a custom function
	-- Used custom function to update the column

CREATE FUNCTION dbo.fnProperCase(@string NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX)
    DECLARE @i INT
    DECLARE @len INT
    DECLARE @c NCHAR(1)
    
    SET @result = LOWER(@string)
    SET @i = 1
    SET @len = LEN(@string)

    WHILE @i <= @len
    BEGIN
        SET @c = SUBSTRING(@result, @i, 1)
        
        IF @i = 1 OR SUBSTRING(@result, @i - 1, 1) = ' '
        BEGIN
            SET @result = STUFF(@result, @i, 1, UPPER(@c))
        END

        SET @i = @i + 1
    END

    RETURN @result
END

UPDATE Reasons
SET Reason = dbo.fnProperCase(Reason);
