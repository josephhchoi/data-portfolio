# WORLD LIFE EXPECTANCY PROJECT: EXPLORATORY DATA ANALYSIS

	# Table of Content:
	# 15-Year Life Expectancy Trend By Country
        # Correlation between life expectancy and GDP
	# Correlation between life expectancy and BMI
        # Average Life Expectancy Comparison: Developed vs. Developing Countries
        # Adult Mortality's Impact on Life Expectancy

	USE world_life_expectancy;
	SELECT * FROM world_life_expectancy;
    
-- 15-YEAR LIFE EXPECTANCY TREND BY COUNTRY --

	-- Part 1: Retrieving Life Expectancy Growth from 2007 to 2022 by country
	SELECT 
		Country, 
		MIN(`Life expectancy`) AS Min_Life_Expectancy, 
		MAX(`Life expectancy`) AS Max_Life_Expectancy,
		ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
	FROM world_life_expectancy
	GROUP BY Country
	HAVING 
		MIN(`Life expectancy`) <> 0 AND
		MAX(`Life expectancy`) <> 0
	ORDER BY Life_increase_15_years DESC
	;

	-- Part 2: Retreiving global average life expectancy by year 
	SELECT Year, ROUND(AVG(`Life expectancy`),1)
	FROM world_life_expectancy
	WHERE 
		`Life expectancy` <> 0 AND
		`Life expectancy` <> 0
	GROUP By Year
	ORDER BY Year
	;

-- CORRELATION BETWEEN LIFE EXPECTANCY AND GDP --

	-- Part 1: Retrieving average life expectancy and average gdp by country
	SELECT 
		Country, 
        ROUND(AVG(`Life expectancy`),1) AS Avg_Life_Exp, 
        ROUND(AVG(GDP)) AS Avg_GDP
	FROM world_life_expectancy
	GROUP BY Country
	HAVING
		Avg_Life_Exp > 0 AND
		Avg_GDP > 0
	ORDER BY Avg_GDP
	;

	-- Part 2: Retrieving count of high & low GDP countries and their respective average life expectancy for correlation analysis
	SELECT
		SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
		ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END), 1) AS High_GDP_Life_Expectancy,
		SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
		ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END), 1) AS Low_GDP_Life_Expectancy
	FROM world_life_expectancy
	;

-- CORRELATION BETWEEN LIFE EXPECTANCY AND BMI --

	-- Part 1: Retrieving average life expectancy and average BMI by country HEADER
	SELECT 
		Country, 
		ROUND(AVG(`Life expectancy`),1) AS Avg_Life_Exp, 
		ROUND(AVG(BMI)) AS Avg_BMI
	FROM world_life_expectancy
	GROUP BY Country
	HAVING
		Avg_Life_Exp > 0 AND
		Avg_BMI > 0
	ORDER BY Avg_BMI DESC
	;

-- AVERAGE LIFE EXPECTANCY COMPARISON: DEVELOPED VS. DEVELOPING COUNTRIES --

	-- Part 1: Retrieving the average life expectancy by status of country
	SELECT 
		Status, 
        COUNT(DISTINCT Country) AS Country_Count, 
        ROUND(AVG(`Life expectancy`),1) AS Avg_Life_Exp
	FROM world_life_expectancy
	GROUP BY Status
	;

-- ADULT MORTALITY'S IMPACT ON LIFE EXPECTANCY

	-- Part 1: Retrieving the rolling total of adult mortality by country by year
	SELECT
		Country,
		Year,
		`Life expectancy`,
		`Adult Mortality`,
		SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Adult_Mortality_Rolling_Total
	FROM world_life_expectancy
	;
