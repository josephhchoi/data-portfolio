----- SETUP -----

-- Ensuring that the 'coviddata' table imported successfully --
SELECT *
FROM portfolioproject.coviddata;

-- Updating the data types of certain columns to the correct type --
UPDATE portfolioproject.coviddata SET `date` = DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'), '%Y-%m-%d'); -- Converting the existing 'date' values to the correct format
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `date` DATE; -- 'date' column: from TEXT to DATE

UPDATE portfolioproject.coviddata SET `total_cases` = NULL WHERE `total_cases` = ''; -- Updating empty string values to NULL
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `total_cases` INT; -- 'total_cases' column: from TEXT to INT

UPDATE portfolioproject.coviddata SET `total_deaths` = NULL WHERE `total_deaths` = ''; -- Updating empty string values to NULL
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `total_deaths` INT; -- 'total_deaths' column: from TEXT to INT

UPDATE portfolioproject.coviddata SET `total_tests` = NULL WHERE `total_tests` = ''; -- Updating empty string values to NULL
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `total_tests` INT; -- 'total_tests' column: from TEXT to INT

UPDATE portfolioproject.coviddata SET `new_tests` = NULL WHERE `new_tests` = ''; -- Updating empty string values to NULL
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `new_tests` INT; -- 'new_tests' column: from TEXT to INT

UPDATE portfolioproject.coviddata SET `new_vaccinations` = NULL WHERE `new_vaccinations` = ''; -- Updating empty string values to NULL
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `new_vaccinations` INT; -- 'new_vaccinations' column: from TEXT to INT

UPDATE portfolioproject.coviddata SET `total_vaccinations` = NULL WHERE `total_vaccinations` = ''; -- Updating empty string values to NULL
ALTER TABLE portfolioproject.coviddata MODIFY COLUMN `total_vaccinations` BIGINT; -- 'total_vaccinations' column: from TEXT to BIGINT

----- DATA EXPLORATION -----

-- 1.) Total Cases vs Total Deaths: Displays COVID-19 fatality probability by country -- 
SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS fatality_rate
FROM portfolioproject.coviddata;
ORDER BY 1,2;

-- 2.) Total Cases vs Population: Displays COVID-19 infection rates by country --
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM portfolioproject.coviddata;
ORDER BY 1,2;

-- 3.) Countries w/ the Highest Infection Rate Compared to Population --
SELECT location, MAX(total_cases) AS max_case_count, population, MAX((total_cases/population))*100 AS max_infection_rate
FROM portfolioproject.coviddata
GROUP BY location, population
ORDER BY 4 DESC;

-- 4.) Countries w/ the Highest Death Count per Population --
SELECT location, sum(new_deaths) AS fatality_count
FROM portfolioproject.coviddata
GROUP BY location
ORDER BY 2 DESC;

-- 5.) Continents w/ the Highest Death Count per Population --
SELECT continent, sum(new_deaths) AS fatality_count
FROM portfolioproject.coviddata
GROUP BY continent
ORDER BY 2 DESC;

-- 6.) Global COVID-19 fatality probability by date --
SELECT date, SUM(new_deaths) AS ttl_deaths, SUM(new_cases) AS ttl_cases, SUM(new_deaths)/SUM(new_cases)*100 AS fatality_rate
FROM portfolioproject.coviddata
GROUP BY date;

-- 7.) Total Population vs Vaccinations: displaying the # of people vaccinated globally via 'CTE' & 'Temp Table' --

-- Using CTE --
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinnated_count)
AS
(
SELECT continent, location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_vaccinnated_count
FROM portfolioproject.coviddata
ORDER BY 2, 3
)
SELECT *, (rolling_vaccinnated_count/population)*100 AS vaccinated_rate
FROM PopvsVac;

-- Using Temp Table --
USE portfolioproject;
DROP TABLE IF EXISTS PopulationVaccinatedRate;
CREATE TEMPORARY TABLE PopulationVaccinatedRate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated_count numeric
);
INSERT INTO PopulationVaccinatedRate
SELECT continent, location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_vaccinnated_count
FROM portfolioproject.coviddata
ORDER BY 2, 3;

SELECT *, (rolling_vaccinated_count/population) AS vaccinated_rate
FROM PopulationVaccinatedRate;

-- 8.) Creating view for future visualizations --
CREATE VIEW PopulationVaccinatedRate AS
SELECT continent, location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_vaccinnated_count
FROM portfolioproject.coviddata
ORDER BY 2, 3;

