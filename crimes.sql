-- ==============================================================================
-- LAPD CRIME DATA ANALYSIS PROJECT
-- DATABASE: PostgreSQL (pgAdmin)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. SCHEMA INITIALIZATION & DATA VERIFICATION
-- ------------------------------------------------------------------------------

-- Create main data table
CREATE TABLE lapd_crime_data (
    dr_no VARCHAR(20) PRIMARY KEY,
    date_rptd TIMESTAMP,
    date_occ TIMESTAMP,
    time_occ INT,
    area INT,
    area_name VARCHAR(100),
    rpt_dist_no INT,
    part_1_2 INT,
    crm_cd INT,
    crm_cd_desc VARCHAR(250),
    mocodes VARCHAR(250),
    vict_age INT,
    vict_sex CHAR(1),
    vict_descent CHAR(1),
    premis_cd INT,
    premis_desc VARCHAR(250),
    weapon_used_cd INT,
    weapon_desc VARCHAR(150),
    status CHAR(2),
    status_desc VARCHAR(100),
    crm_cd_1 INT,
    crm_cd_2 INT,
    crm_cd_3 INT,
    crm_cd_4 INT,
    location VARCHAR(250),
    cross_street VARCHAR(250),
    lat NUMERIC(9, 6),
    lon NUMERIC(9, 6)
);

-- Inspect imported records
SELECT * FROM lapd_crime_data;


-- ------------------------------------------------------------------------------
-- 2. DESCRIPTIVE & OVERVIEW QUERIES
-- ------------------------------------------------------------------------------

-- Top 20 most frequent crime descriptions and their global share
SELECT 
    crm_cd_desc, 
    COUNT(*) AS total_incidents,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_of_total
FROM lapd_crime_data
GROUP BY crm_cd_desc
ORDER BY total_incidents DESC
LIMIT 20;

-- Crime volume and severity breakdown across LAPD Divisions
SELECT 
    area_name, 
    COUNT(*) AS incident_count,
    COUNT(CASE WHEN part_1_2 = 1 THEN 1 END) AS serious_felonies_part1,
    COUNT(CASE WHEN part_1_2 = 2 THEN 1 END) AS minor_offenses_part2
FROM lapd_crime_data
GROUP BY area_name
ORDER BY incident_count DESC;


-- ------------------------------------------------------------------------------
-- 3. TEMPORAL & SEASONAL TRENDS
-- ------------------------------------------------------------------------------

-- Peak crime hours combined with day of the week tracking
SELECT 
    EXTRACT(DOW FROM date_occ) AS day_of_week, -- 0 = Sunday, 6 = Saturday
    TO_CHAR(date_occ, 'Day') AS day_name,
    FLOOR(time_occ / 100) AS hour_of_day,      -- Converts military format (e.g., 2230 -> 22)
    COUNT(*) AS incident_count
FROM lapd_crime_data
GROUP BY day_of_week, day_name, hour_of_day
ORDER BY incident_count DESC
LIMIT 20;

-- Shift in crime profiles by time of day (Day vs. Night distributions)
SELECT 
    crm_cd_desc,
    COUNT(CASE WHEN time_occ >= 600 AND time_occ < 1800 THEN 1 END) AS daytime_incidents,
    COUNT(CASE WHEN time_occ >= 1800 OR time_occ < 600 THEN 1 END) AS nighttime_incidents,
    COUNT(*) AS total_incidents,
    ROUND(COUNT(CASE WHEN time_occ >= 1800 OR time_occ < 600 THEN 1 END) * 100.0 / COUNT(*), 2) AS nighttime_percentage
FROM lapd_crime_data
GROUP BY crm_cd_desc
HAVING COUNT(*) > 10
ORDER BY nighttime_percentage DESC;

-- Weekend Surge Analysis: Percentage fluctuation vs. standard weekday averages
SELECT 
    crm_cd_desc,
    ROUND(COUNT(CASE WHEN EXTRACT(DOW FROM date_occ) IN (0, 6) THEN 1 END) * 1.0 / 2, 1) AS avg_weekend_daily_count,
    ROUND(COUNT(CASE WHEN EXTRACT(DOW FROM date_occ) NOT IN (0, 6) THEN 1 END) * 1.0 / 5, 1) AS avg_weekday_daily_count,
    ROUND(
        ((COUNT(CASE WHEN EXTRACT(DOW FROM date_occ) IN (0, 6) THEN 1 END) * 1.0 / 2) - 
         (COUNT(CASE WHEN EXTRACT(DOW FROM date_occ) NOT IN (0, 6) THEN 1 END) * 1.0 / 5)) * 100.0 / 
        NULLIF(COUNT(CASE WHEN EXTRACT(DOW FROM date_occ) NOT IN (0, 6) THEN 1 END) * 1.0 / 5, 0), 2
    ) AS weekend_surge_percentage
FROM lapd_crime_data
GROUP BY crm_cd_desc
HAVING COUNT(*) > 20
ORDER BY weekend_surge_percentage DESC;

-- High-risk 4-hour temporal blocks parsed by premise type
SELECT 
    premis_desc,
    CASE 
        WHEN time_occ BETWEEN 0 AND 400 THEN 'Late Night (00:00-04:00)'
        WHEN time_occ BETWEEN 401 AND 800 THEN 'Early Morning (04:01-08:00)'
        WHEN time_occ BETWEEN 801 AND 1200 THEN 'Morning (08:01-12:00)'
        WHEN time_occ BETWEEN 1201 AND 1600 THEN 'Afternoon (12:01-16:00)'
        WHEN time_occ BETWEEN 1601 AND 2000 THEN 'Evening (16:01-20:00)'
        ELSE 'Night (20:01-23:59)'
    END AS time_window,
    COUNT(*) AS incident_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY premis_desc), 2) AS pct_of_premise_total
FROM lapd_crime_data
GROUP BY premis_desc, time_window
HAVING COUNT(*) > 10
ORDER BY premis_desc, incident_count DESC;


-- ------------------------------------------------------------------------------
-- 4. VICTIM & ENVIRONMENT TARGET PROFILING
-- ------------------------------------------------------------------------------

-- Victim demographic tracking across primary crime categories
SELECT 
    crm_cd_desc,
    ROUND(AVG(vict_age), 1) AS avg_victim_age,
    COUNT(CASE WHEN vict_sex = 'F' THEN 1 END) AS female_victims,
    COUNT(CASE WHEN vict_sex = 'M' THEN 1 END) AS male_victims
FROM lapd_crime_data
WHERE vict_age > 0 AND vict_sex IN ('F', 'M')
GROUP BY crm_cd_desc
HAVING COUNT(*) > 5
ORDER BY AVG(vict_age) DESC;

-- High-risk premise vulnerabilities across victim age and biological sex
SELECT 
    premis_desc,
    ROUND(AVG(vict_age), 1) AS avg_victim_age,
    COUNT(*) AS total_crimes,
    ROUND(COUNT(CASE WHEN vict_sex = 'F' THEN 1 END) * 100.0 / COUNT(*), 2) AS female_victim_pct,
    ROUND(COUNT(CASE WHEN vict_sex = 'M' THEN 1 END) * 100.0 / COUNT(*), 2) AS male_victim_pct
FROM lapd_crime_data
WHERE vict_age > 0 AND vict_sex IN ('F', 'M')
GROUP BY premis_desc
HAVING COUNT(*) > 20
ORDER BY avg_victim_age DESC;

-- Weapon-Premise Correlations: Top 3 weapon categories utilized by location type
WITH ranked_weapons AS (
    SELECT 
        premis_desc,
        weapon_desc,
        COUNT(*) AS incident_count,
        RANK() OVER (PARTITION BY premis_desc ORDER BY COUNT(*) DESC) AS weapon_rank_in_premise
    FROM lapd_crime_data
    WHERE weapon_desc IS NOT NULL 
      AND weapon_desc NOT IN ('UNKNOWN', 'STRONG-ARM')
    GROUP BY premis_desc, weapon_desc
)
SELECT 
    premis_desc,
    weapon_desc,
    incident_count,
    weapon_rank_in_premise
FROM ranked_weapons
WHERE weapon_rank_in_premise <= 3
ORDER BY premis_desc, incident_count DESC;


-- ------------------------------------------------------------------------------
-- 5. OPERATIONAL EFFICIENCY & CASE COMPLEXITY
-- ------------------------------------------------------------------------------

-- Complex criminal events containing multiple secondary offenses
SELECT 
    dr_no,
    crm_cd_desc,
    (CASE WHEN crm_cd_1 IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN crm_cd_2 IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN crm_cd_3 IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN crm_cd_4 IS NOT NULL THEN 1 ELSE 0 END) AS total_offenses_committed,
    status_desc
FROM lapd_crime_data
WHERE crm_cd_2 IS NOT NULL
ORDER BY total_offenses_committed DESC
LIMIT 10;

-- Reporting Lag: Average time passed before crimes are officially recorded
SELECT 
    crm_cd_desc,
    COUNT(*) AS total_incidents,
    ROUND(AVG(date_rptd::date - date_occ::date), 1) AS avg_days_to_report,
    MAX(date_rptd::date - date_occ::date) AS max_days_to_report
FROM lapd_crime_data
GROUP BY crm_cd_desc
HAVING COUNT(*) >= 5
ORDER BY avg_days_to_report DESC;

-- Operational Closure: Case arrest rates and backlog indicators by Area
SELECT 
    area_name,
    COUNT(*) AS total_crimes,
    ROUND(COUNT(CASE WHEN status IN ('AA', 'JA') THEN 1 END) * 100.0 / COUNT(*), 2) AS arrest_rate_percentage,
    ROUND(COUNT(CASE WHEN status = 'IC' THEN 1 END) * 100.0 / COUNT(*), 2) AS ongoing_investigation_percentage
FROM lapd_crime_data
GROUP BY area_name
ORDER BY arrest_rate_percentage DESC;

-- Investigation Backlog Tracking: Open Part-1 felonies ranked by days unresolved
SELECT 
    dr_no,
    area_name,
    crm_cd_desc,
    date_occ,
    (CURRENT_DATE - date_occ::date) AS days_unresolved
FROM lapd_crime_data
WHERE status = 'IC' 
  AND part_1_2 = 1
ORDER BY days_unresolved DESC
LIMIT 15;
