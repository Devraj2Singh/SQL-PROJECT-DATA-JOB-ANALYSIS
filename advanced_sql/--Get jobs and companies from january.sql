--Get jobs and companies from january
SELECT job_title_short,
    company_id,
    job_location
FROM january_jobs
UNION All
--Get jobs and companies from february
SELECT job_title_short,
    company_id,
    job_location
FROM february_jobs
UNION ALL
--Get jobs and companies from March
SELECT job_title_short,
    company_id,
    job_location
FROM march_jobs;
/*
 Find job postings from the first quarter that have a salary grater than $70k
 - Combine job postings tables from the first quarter of 2023 (Jan_Mar)
 - Gets job postings with an average yearly salary > $70000
 */
SELECT job_title_short,
    job_location,
    job_via,
    job_posted_date::DATE,
    salary_year_avg
FROM (
        SELECT *
        FROM january_jobs
        UNION ALL
        SELECT *
        FROM february_jobs
        UNION ALL
        SELECT *
        FROM march_jobs
    ) AS quarter1_job_postings
WHERE salary_year_avg > 70000
    AND job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC --🟩 Problem 1    
    /*Create a unified query categorizing job postings into two groups: those With Salary Info and those Without Salary Info.
     Return job_id, job_title, and a new column named salary_info.*/
    (
        SELECT job_id,
            job_title,
            'With Salary Info' AS salary_info
        FROM job_postings_fact
        WHERE salary_year_avg IS NOT NULL
            OR salary_hour_avg IS NOT NULL
    )
UNION ALL
(
    SELECT job_id,
        job_title,
        'Without Salary Info' AS salary_info
    FROM job_postings_fact
    WHERE salary_year_avg IS NULL
        AND salary_hour_avg IS NULL
)
ORDER BY salary_info DESC,
    job_id;
--🟨 Problem 2
/*Retrieve the job id, job title short, job location, job via, skill and skill type for each job posting from the first quarter 
 (January to March). Using a subquery to combine job postings from the first quarter (these tables were created in the Advanced 
 Section - Practice Problem 6 Video) Only include postings with an average yearly salary greater than $70,000.*/
SELECT q.job_id,
    q.job_title_short,
    q.job_location,
    q.job_via,
    s.skill_id,
    s.skills
FROM (
        SELECT *
        FROM january_jobs
        UNION ALL
        SELECT *
        FROM february_jobs
        UNION ALL
        SELECT *
        FROM march_jobs
    ) AS q
    LEFT JOIN skills_job_dim AS sj ON q.job_id = sj.job_id
    LEFT JOIN skills_dim AS s ON sj.skill_id = s.skill_id
WHERE q.salary_year_avg > 70000
ORDER BY q.job_id;
--🟥 Problem 3 **MOST IMPORTANT**
/*Analyze the monthly demand for skills by counting the number of job postings for each skill in the first quarter 
 (January to March), utilizing data from separate tables for each month. Ensure to include skills from all job postings 
 across these months. The tables for the first quarter job postings were created in Practice Problem 6.*/
SELECT s.skills AS skill_name,
    COUNT(DISTINCT q.job_id) AS total_q1_job_postings
FROM (
        SELECT job_id,
            job_posted_date
        FROM january_jobs
        UNION ALL
        SELECT job_id,
            job_posted_date
        FROM february_jobs
        UNION ALL
        SELECT job_id,
            job_posted_date
        FROM march_jobs
    ) AS q
    LEFT JOIN skills_job_dim AS sj ON q.job_id = sj.job_id
    LEFT JOIN skills_dim AS s ON sj.skill_id = s.skill_id
GROUP BY s.skills
ORDER BY total_q1_job_postings DESC;
--CORRECT ANSWER
-- CTE for combining job postings from January, February, and March
WITH combined_job_postings AS (
    SELECT job_id,
        job_posted_date
    FROM january_jobs
    UNION ALL
    SELECT job_id,
        job_posted_date
    FROM february_jobs
    UNION ALL
    SELECT job_id,
        job_posted_date
    FROM march_jobs
),
-- CTE for calculating monthly skill demand based on the combined postings
monthly_skill_demand AS (
    SELECT skills_dim.skills,
        EXTRACT(
            YEAR
            FROM combined_job_postings.job_posted_date
        ) AS year,
        EXTRACT(
            MONTH
            FROM combined_job_postings.job_posted_date
        ) AS month,
        COUNT(combined_job_postings.job_id) AS postings_count
    FROM combined_job_postings
        INNER JOIN skills_job_dim ON combined_job_postings.job_id = skills_job_dim.job_id
        INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    GROUP BY skills_dim.skills,
        year,
        month
) -- Main query to display the demand for each skill during the first quarter
SELECT skills,
    year,
    month,
    postings_count
FROM monthly_skill_demand
ORDER BY skills,
    year,
    month;