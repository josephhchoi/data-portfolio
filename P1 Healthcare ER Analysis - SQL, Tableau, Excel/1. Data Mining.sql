----- SETUP ------

-- Ensuring that the 'hospital_er' table imported successfully --
SELECT *
FROM portfolioproject.hospital_er;

----- DATA MINING -----

-- 1.) Patient Demographics Analysis --

	-- Distribution of Patients by Age: --
SELECT
	patient_age,
    COUNT(*) AS number_of_patients
FROM portfolioproject.hospital_er
GROUP BY
	patient_age
ORDER BY
	patient_age;
    
    -- Distribution of Patients by Gender: --
SELECT
	patient_gender,
    COUNT(*) AS number_of_patients
FROM portfolioproject.hospital_er
GROUP BY
	patient_gender
ORDER BY
	patient_gender;
    
    -- Distribution of Patients by Race: --
SELECT
	patient_race,
    COUNT(*) AS number_of_patients
FROM portfolioproject.hospital_er
GROUP BY
	patient_race
ORDER BY
	patient_race;

-- 2.) Patient Satisfaction Analysis --

	-- Average Patient Satisfaction Score by Year and Month --
SELECT
	YEAR(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')) AS year,
	MONTH(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')) AS month,
    AVG(patient_sat_score) AS average_satisfaction_score
FROM portfolioproject.hospital_er
WHERE
	patient_sat_score <> ''
GROUP BY
	YEAR(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')),
    MONTH(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'))
ORDER BY
	YEAR(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')),
    MONTH(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'))

-- 3.) Admission and Wait Time Analysis --

	-- Metrics: --
		-- AVG/MAX/MIN patient wait time calculation
		-- Total admission count
		-- Patient count with wait times over 30 min
		-- Patient count with wait times under 30 min
SELECT
    AVG(patient_waittime) AS average_wait_time,
    MAX(patient_waittime) AS max_wait_time,
    MIN(patient_waittime) AS min_wait_time,
	COUNT(DISTINCT patient_id) AS total_admissions,
    COUNT(DISTINCT CASE WHEN patient_waittime > 30 THEN patient_id END) AS patients_waiting_over_30_min,
    COUNT(DISTINCT CASE WHEN patient_waittime < 30 THEN patient_id END) AS patients_waiting_under_30_min
FROM
    portfolioproject.hospital_er;
    
    -- % of Patients Waiting Under/Over 30 Min --
SELECT
	ROUND(((patients_waiting_over_30_min / total_admissions)*100),2) AS percentage_over30,
    ROUND(((patients_waiting_under_30_min / total_admissions)*100),2) AS percentage_under30
FROM (
SELECT
    AVG(patient_waittime) AS average_wait_time,
    MAX(patient_waittime) AS max_wait_time,
    MIN(patient_waittime) AS min_wait_time,
	COUNT(DISTINCT patient_id) AS total_admissions,
    COUNT(DISTINCT CASE WHEN patient_waittime > 30 THEN patient_id END) AS patients_waiting_over_30_min,
    COUNT(DISTINCT CASE WHEN patient_waittime < 30 THEN patient_id END) AS patients_waiting_under_30_min
FROM
    portfolioproject.hospital_er
) AS subquery;

-- 4.) Department Referral Analysis --

	-- Metrics: --
		-- Total referral count by department
		-- Referral % distribution by department
SELECT
    department_referral,
    COUNT(*) AS referral_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM portfolioproject.hospital_er), 2) AS referral_percentage
FROM
    portfolioproject.hospital_er
WHERE
    department_referral <> ''
GROUP BY
	department_referral
ORDER BY
    referral_count DESC;

-- 5.) Seasonal Patterns Analysis

	-- Metrics: --
		-- Season identification using 'CASE()'
        -- Total hospital visits
        -- Visitation % distribution by season
SELECT
    season,
    total_visits,
    ROUND((total_visits / SUM(total_visits) OVER ()) * 100) AS season_percentage
FROM (
    SELECT
        CASE
            WHEN MONTH(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')) BETWEEN 3 AND 5 THEN 'Spring'
            WHEN MONTH(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')) BETWEEN 6 AND 8 THEN 'Summer'
            WHEN MONTH(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s')) BETWEEN 9 AND 11 THEN 'Fall'
            ELSE 'Winter'
        END AS season,
        COUNT(*) AS total_visits
    FROM
        portfolioproject.hospital_er
    GROUP BY
        season
) AS subquery;
