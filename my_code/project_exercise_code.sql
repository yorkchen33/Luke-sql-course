-- 1. What are the top-paying jobs for my role?
-- 2. What are the skills required for these top-paying roles?
-- 3. What are the most in-demand skills for my role?
-- 4. What are the top skills based on salary for my role?
-- 5. What are the most optimal skills to learn?
-- a. Optimal: High Demand AND High Paying



-- 1 Top paying job
-- identify the top 10 highest paying data analyst job that can work remotely

SELECT  
    job_id,
    job_title,
    cd.name AS company,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM
    job_postings_fact jpf
LEFT JOIN
    company_dim cd ON cd.company_id = jpf.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND
    salary_year_avg IS NOT NULL
-- Modify to fit your need
ORDER BY
    salary_year_avg DESC
LIMIT 10;

-- 2 Skills for top paying job

WITH Top_paying_jobs AS (
    SELECT  
        job_id,
        job_title,
        cd.name AS company,
        salary_year_avg
    FROM
        job_postings_fact jpf
    LEFT JOIN
        company_dim cd ON cd.company_id = jpf.company_id
    WHERE
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    -- Modify to fit your need
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT
    skills,
    job_title,
    company,
    salary_year_avg
FROM
    Top_paying_jobs tpj
INNER JOIN
    skills_job_dim sjd on sjd.job_id = tpj.job_id
INNER JOIN
    skills_dim sd ON sd.skill_id = sjd.skill_id;