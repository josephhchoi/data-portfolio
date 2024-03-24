# US HOUSEHOLD INCOME PROJECT: EXPLORATORY DATA ANALYSIS

	# Table of Content: 
		# Area of Land & Area of Water Analysis in US
        # Average & Median Household Income Analysis in US
        
	USE us_house_income;
	SELECT * FROM us_household_income; 
	SELECT * FROM us_household_income_statistics;
    
    
-- AREA OF LAND & AREA OF WATER ANALYSIS IN US --

	-- Part 1: Identifying Top 10 Largest States by Land -- 
	SELECT 
		State_Name, 
		SUM(ALand) AS Area_of_Land
	FROM us_household_income
	GROUP BY State_Name
	ORDER BY 2 DESC
	LIMIT 10
	;

	-- Part 2: Identifying Top 10 Largest States by Water -- 
	SELECT 
		State_Name, 
		SUM(AWater) AS Area_of_Water
	FROM us_household_income
	GROUP BY State_Name
	ORDER BY 2 DESC
	LIMIT 10
	;
    
-- AVERAGE & MEDIAN HOUSEHOLD INCOME ANALYSIS IN US --

	-- Part 1: Identifying the National Average & Median Household Income
	SELECT 
		ROUND(AVG(us.Mean)) AS Average_Income,
		ROUND(AVG(us.Median)) AS Median_Income
	FROM us_household_income u
	JOIN us_household_income_statistics us
		ON u.id = us.id
	WHERE Mean <> 0 # Removing Outliers
	;

	-- Part 2: Identifying the Average and Median Income Household Income by State
	SELECT 
		u.State_Name,
		ROUND(AVG(us.Mean)) AS Average_Income,
		ROUND(AVG(us.Median)) AS Median_Income
	FROM us_household_income u
	JOIN us_household_income_statistics us
		ON u.id = us.id
	WHERE Mean <> 0 # Removing Outliers
	GROUP BY u.State_Name
	ORDER BY 2 DESC
	;
    
	-- Part 3: Identifying the Average and Median Income Household Income by City
	SELECT 
        u.City,
		u.State_Name,
		ROUND(AVG(us.Mean)) AS Average_Income,
		ROUND(AVG(us.Median)) AS Median_Income
	FROM us_household_income u
	JOIN us_household_income_statistics us
		ON u.id = us.id
	WHERE Mean <> 0 # Removing Outliers
	GROUP BY u.State_Name, u.City
	ORDER BY 3 DESC
	;
    
	-- Part 4: Identifying the Average and Median Income Household Income by Area Type
	SELECT 
		u.Type,
        COUNT(u.Type) AS Count_Type,
		ROUND(AVG(us.Mean)) AS Average_Income,
		ROUND(AVG(us.Median)) AS Median_Income
	FROM us_household_income u
	JOIN us_household_income_statistics us
		ON u.id = us.id
	WHERE Mean <> 0
	GROUP BY u.Type
    HAVING Count_Type > 100 # Removing Outliers
	ORDER BY 3 DESC
	;