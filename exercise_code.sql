SELECT *
FROM job_postings_fact
LIMIT 10;

SELECT 
    jpf.job_title_short AS title,
    jpf.job_posted_date::DATE AS date_time
FROM 
    job_postings_fact AS jpf
LIMIT 5;

SELECT 
    jpf.job_title_short AS title,
    jpf.job_posted_date AT TIME ZONE 'EST' AT TIME ZONE 'EST' AS date_time 
FROM 
    job_postings_fact AS jpf
LIMIT 5;

SELECT
    Count(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM
    job_postings_fact
WHERE   
    job_title_short like '%Data Analyst%'
GROUP BY
    date_month
ORDER BY
    date_month ASC;

-- DATE pp1
SELECT
    AVG(jpf.salary_year_avg) AS yearly_salary,
    AVG(jpf.salary_hour_avg) AS hourly_salary
FROM
    job_postings_fact AS jpf
WHERE
    jpf.job_posted_date::DATE > '2023-06-01'::Date
    ;

-- DATE pp2
SELECT
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(job_id) as job_posted_each_month
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2023
GROUP BY
    EXTRACT(MONTH FROM job_posted_date);

-- PP6
-- January
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

-- April
CREATE TABLE april_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 4;

-- May
CREATE TABLE may_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 5;

-- June
CREATE TABLE june_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 6;

-- July
CREATE TABLE july_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 7;

-- August
CREATE TABLE august_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 8;

-- September
CREATE TABLE september_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 9;

-- October
CREATE TABLE october_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 10;

-- November
CREATE TABLE november_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 11;

-- December
CREATE TABLE december_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 12;

SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact;

-- Subqueries example
SELECT
    company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN (
    SELECT company_id
    FROM job_postings_fact
    WHERE job_no_degree_mention = true
    ORDER BY company_id
);

-- CTE example
WITH company_job_count AS (
    SELECT
        jpf.company_id,  
        COUNT(jpf.job_id) AS jobs
    FROM
        job_postings_fact AS jpf
    GROUP BY
        jpf.company_id
)

SELECT
    cd.company_id,
    cd.name AS company_name,
    cjc.jobs
FROM
    company_dim AS cd
LEFT JOIN
    company_job_count AS cjc ON cd.company_id = cjc.company_id
ORDER BY
    cjc.jobs DESC;

-- Subqueries and CTE pp1

-- SELECT
--     sd.skills AS skills,
--     COUNT(job_id) AS total_jobs
-- FROM
--     skills_job_dim AS sjd
-- LEFT JOIN
--     skills_dim AS sd ON sd.skill_id = sjd.skill_id
-- GROUP BY
--     sd.skills
-- ORDER BY
--     total_jobs DESC
-- LIMIT 5;

SELECT
    sd.skills AS skills,
    sjd.total_jobs
FROM
    (SELECT
        skill_id,
        COUNT(job_id) AS total_jobs
     FROM
        skills_job_dim
     GROUP BY
        skill_id
     ORDER BY
        total_jobs DESC
     LIMIT 5) AS sjd
JOIN
    skills_dim AS sd ON sd.skill_id = sjd.skill_id;

-- PP7
-- Find the count of the number of remote job postings per skill
-- remote = Anywhere in job_location

WITH job_loc_categories AS (
    SELECT
        job_id,
        CASE 
            WHEN jpf.job_work_from_home = True THEN 'Remote'
            WHEN jpf.job_location LIKE '5New York%' THEN 'Local'
            ELSE 'Not remote'
        END AS location_type
    FROM job_postings_fact AS jpf
)

SELECT
    sd.skills,
    COUNT(jpf.job_id) AS count
FROM
    job_postings_fact AS jpf    
INNER JOIN
    skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
INNER JOIN
    skills_dim AS sd ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_id IN (
        SELECT job_id
        FROM job_loc_categories
        WHERE location_type = 'Remote') And
    jpf.job_title_short = 'Data Analyst'
GROUP BY
    sd.skill_id
ORDER BY
    count DESC
LIMIT 5;

-- PP8
-- Find job from quarter 1 that have a salary > $70k
WITH jobs_in_quarter1 AS (
    SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
)

SELECT * 
FROM jobs_in_quarter1
WHERE jobs_in_quarter1.salary_year_avg > 70000;
