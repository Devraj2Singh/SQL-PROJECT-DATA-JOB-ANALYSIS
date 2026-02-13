--Subqueries:
SELECT *
FROM (
        SELECT *
        FROM job_postings_fact
        WHERE EXTRACT (
                MONTH
                FROM job_posted_date
            ) = 1
    ) AS january_jobs;
--Common Table Expressions(CTEs):
WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (
            MONTH
            FROM job_posted_date
        ) = 1
)
SELECT *
FROM january_jobs;
--Subqueries
SELECT company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
        SELECT company_id
        FROM job_postings_fact
        WHERE job_no_degree_mention = TRUE
    ) --CTEs- Common Table Expression
    /*
     Find the comapnies that have the most job openings.
     -Get the total number of job postings per company id
     -Return the total number of jobs with the company name
     */
    WITH company_job_count AS (
        SELECT company_id,
            COUNT(*) AS total_jobs
        FROM job_postings_fact
        GROUP BY company_id
    )
SELECT company_dim.name AS company_name,
    company_job_count.total_jobs
FROM company_dim
    LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC;
/*
 **Imp question**
 Find the count of the number of remote job postings per skill
 -Display the top 5 skills by their demand in remote jobs
 -Include skill ID, name, and count of postings requiring the skill
 */
WITH remote_job_skills AS (
    SELECT skill_id,
        COUNT(*) AS skill_count
    FROM skills_job_dim AS skill_to_job
        INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skill_to_job.job_id
    WHERE job_postings.job_work_from_home = TRUE
        AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)
SELECT skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_job_skills
    INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5;
/*    
 🟩 Problem 1
 Identify the top 5 skills that are most frequently mentioned in job postings. Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table and then join this result with the skills_dim table to get the skill names.
 */
--Using CTE
WITH top_5_skills AS (
    SELECT skill_id,
        Count (*) AS jobs_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER By jobs_count DESC
    LIMIT 5
)
SELECT skills.skill_id,
    skills AS skill_name,
    jobs_count
FROM top_5_skills
    INNER JOIN skills_dim AS skills ON skills.skill_id = top_5_skills.skill_id --Using subquery
SELECT skills_dim.skills
FROM skills_dim
    INNER JOIN (
        SELECT skill_id,
            COUNT(job_id) AS skill_count
        FROM skills_job_dim
        GROUP BY skill_id
        ORDER BY COUNT(job_id) DESC
        LIMIT 5
    ) AS top_skills ON skills_dim.skill_id = top_skills.skill_id
ORDER BY top_skills.skill_count DESC;
--🟨 Problem 2 Imp Ques
SELECT company_id,
    job_count,
    CASE
        WHEN job_count < 10 THEN 'Small'
        WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM (
        SELECT company_id,
            COUNT(job_id) AS job_count
        FROM job_postings_fact
        GROUP BY company_id
    ) AS company_jobs
ORDER BY job_count DESC;
--correct answer
SELECT company_id,
    name,
    -- Categorize companies
    CASE
        WHEN job_count < 10 THEN 'Small'
        WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM (
        -- Subquery to calculate number of job postings per company 
        SELECT company_dim.company_id,
            company_dim.name,
            COUNT(job_postings_fact.job_id) AS job_count
        FROM company_dim
            INNER JOIN job_postings_fact ON company_dim.company_id = job_postings_fact.company_id
        GROUP BY company_dim.company_id,
            company_dim.name
    ) AS company_job_count;
--🟥 Problem 3
/*
 Your goal is to find the names of companies that have an average salary greater than the overall average salary across all job postings.
 You'll need to use two tables: company_dim (for company names) and job_postings_fact (for salary data). The solution requires using subqueries.
 */
--Wrong 
SELECT AVG(salary_year_avg) as avg_salary
FROM job_postings_fact
SELECT company_id,
    AVG(salary_year_avg) as avg_salary_yearly
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY company_id;
SELECT company_dim.name
FROM (
        SELECT company_id,
            AVG(salary_year_avg) as avg_salary_yearly
        FROM job_postings_fact
        WHERE salary_year_avg IS NOT NULL
        GROUP BY company_id
    ) AS --correct
    --Most Imp
SELECT company_dim.name
FROM company_dim
    INNER JOIN (
        -- Subquery to calculate average salary per company
        SELECT company_id,
            AVG(salary_year_avg) AS avg_salary
        FROM job_postings_fact
        GROUP BY company_id
    ) AS company_salaries ON company_dim.company_id = company_salaries.company_id -- Filter for companies with an average salary greater than the overall average
WHERE company_salaries.avg_salary > (
        -- Subquery to calculate the overall average salary
        SELECT AVG(salary_year_avg)
        FROM job_postings_fact
    );
--CTEs
--🟩 Problem 1
/*Identify companies with the most diverse (unique) job titles. 
 Use a CTE to count the number of unique job titles per company, 
 then select companies with the highest diversity in job titles.*/
WITH title_diversity AS (
    SELECT company_id,
        COUNT(DISTINCT job_title) AS unique_titles
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT company_dim.name,
    title_diversity.unique_titles
FROM title_diversity
    INNER JOIN company_dim ON title_diversity.company_id = company_dim.company_id
ORDER BY unique_titles DESC
LIMIT 5;
--🟨 Problem 2
-- gets average job salary for each country
WITH avg_salaries AS (
    SELECT job_country,
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY job_country
)
SELECT -- Gets basic job info
    job_postings.job_id,
    job_postings.job_title,
    companies.name AS company_name,
    job_postings.salary_year_avg AS salary_rate,
    -- categorizes the salary as above or below average the average salary for the country
    CASE
        WHEN job_postings.salary_year_avg > avg_salaries.avg_salary THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_category,
    -- gets the month and year of the job posting date
    EXTRACT(
        MONTH
        FROM job_postings.job_posted_date
    ) AS posting_month
FROM job_postings_fact as job_postings
    INNER JOIN company_dim as companies ON job_postings.company_id = companies.company_id
    INNER JOIN avg_salaries ON job_postings.job_country = avg_salaries.job_country
ORDER BY -- Sorts it by the most recent job postings
    posting_month desc --🟥 Problem 3
    -- Counts the distinct skills required for each company's job posting
    WITH required_skills AS (
        SELECT companies.company_id,
            COUNT(DISTINCT skills_to_job.skill_id) AS unique_skills_required
        FROM company_dim AS companies
            LEFT JOIN job_postings_fact as job_postings ON companies.company_id = job_postings.company_id
            LEFT JOIN skills_job_dim as skills_to_job ON job_postings.job_id = skills_to_job.job_id
        GROUP BY companies.company_id
    ),
    -- Gets the highest average yearly salary from the jobs that require at least one skills 
    max_salary AS (
        SELECT job_postings.company_id,
            MAX(job_postings.salary_year_avg) AS highest_average_salary
        FROM job_postings_fact AS job_postings
        WHERE job_postings.job_id IN (
                SELECT job_id
                FROM skills_job_dim
            )
        GROUP BY job_postings.company_id
    ) -- Joins 2 CTEs with table to get the query
SELECT companies.name,
    required_skills.unique_skills_required as unique_skills_required,
    --handle companies w/o any skills required
    max_salary.highest_average_salary
FROM company_dim AS companies
    LEFT JOIN required_skills ON companies.company_id = required_skills.company_id
    LEFT JOIN max_salary ON companies.company_id = max_salary.company_id
ORDER BY companies.name;