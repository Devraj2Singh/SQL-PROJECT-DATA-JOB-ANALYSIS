SELECT job_title_short AS title,
  job_location AS location,
  job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'IOT' AS date_time,
  EXTRACT(
    MONTH
    FROM job_posted_date
  ) AS date_month,
  EXTRACT(
    YEAR
    FROM job_posted_date
  ) AS date_year
FROM job_postings_fact
LIMIT 5;
SELECT COUNT(job_id) AS job_posted_count,
  EXTRACT(
    MONTH
    FROM job_posted_date
  ) AS month
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY month
ORDER BY job_posted_count DESC;
--Practice Problem 6
--January   
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
    MONTH
    FROM job_posted_date
  ) = 1;
--February
CREATE TABLE February_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
    MONTH
    FROM job_posted_date
  ) = 2;
--March         
CREATE TABLE March_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
    MONTH
    FROM job_posted_date
  ) = 3;
SELECT job_posted_date
FROM March_jobs;
--*DATE FUNCTIONS*
--ADVANCE PROBLEM 1
--Find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) for job postings using the job_postings_fact table that were posted after June 1, 2023. Group the results by job schedule type. Order by the job_schedule_type in ascending order.   
SELECT job_schedule_type,
  AVG(salary_year_avg) AS salary_avg,
  AVG(salary_hour_avg) AS salary_hourly
FROM job_postings_fact
WHERE job_posted_date::date > '2023-06-01'
GROUP BY job_schedule_type
ORDER BY job_schedule_type;
--Advance Problem 2
--Count the number of job postings for each month, adjusting the job_posted_date to be in 'America/New_York' time zone before extracting the month. Assume the job_posted_date is stored in UTC. Group by and order by the month.
SELECT EXTRACT(
    MONTH
    FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York'
  ) AS month,
  COUNT(*) AS postings_count
FROM job_postings_fact
GROUP BY month
ORDER BY month;
--Advance Problem 3
--Find companies (include company name) that have posted jobs offering health insurance, where these postings were made in the second quarter of 2023. Use date extraction to filter by quarter. And order by the job postings count from highest to lowest.
SELECT company_dim.name AS company_name,
  COUNT(job_postings_fact.job_id) AS job_postings_count
FROM job_postings_fact
  INNER JOIN company_dim on job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_health_insurance = TRUE
  AND EXTRACT(
    QUARTER
    FROM job_postings_fact.job_posted_date
  ) = 2
GROUP BY company_dim.name
HAVING COUNT(job_postings_fact.job_id) > 0
ORDER BY job_postings_count DESC;
--*CASE Statements*
/*Label new column as follows:
 - 'Anywhere' jobs as 'Remote'
 - 'New York, NY' jobs as 'Local'
 - Otherwise 'Onsite'*/
SELECT job_title_short,
  job_location,
  CASE
    WHEN job_location = 'Anywhere' THEN 'Remote'
    WHEN job_location = 'New York, NY' THEN 'Local'
    ELSE 'Onsite'
  END AS location_category
FROM job_postings_fact;
SELECT COUNT(job_id) AS number_of_jobs,
  CASE
    WHEN job_location = 'Anywhere' THEN 'Remote'
    WHEN job_location = 'New York, NY' THEN 'Local'
    ELSE 'Onsite'
  END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;
--🟩 Problem 1
/*From the job_postings_fact table, categorize the salaries from job postings that are data analyst jobs, and that have yearly salary information. Put salary into 3 different categories:
 
 If the salary_year_avg is greater than or equal to $100,000, then return ‘high salary’.
 If the salary_year_avg is greater than or equal to $60,000 but less than $100,000, then return ‘Standard salary.’
 If the salary_year_avg is below $60,000 return ‘Low salary’.
 Also, order from the highest to the lowest salaries.*/
SELECT job_id,
  job_title,
  salary_year_avg,
  CASE
    WHEN salary_year_avg >= 100000 THEN 'High salary'
    WHEN salary_year_avg >= 60000
    AND salary_year_avg < 100000 THEN 'Standard salary'
    WHEN salary_year_avg < 60000 THEN 'Low salary'
  END AS salaries
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
  AND job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;
--🟨 Problem 2
/*Count the number of unique companies that offer work from home (WFH) versus those requiring work to be on-site. Use the job_postings_fact table to count and compare the distinct companies based on their WFH policy (job_work_from_home).*/
SELECT COUNT (DISTINCT job_id) AS number_of_jobs,
  CASE
    WHEN job_work_from_home = TRUE THEN 'wfm_jobs'
    ELSE 'on-site'
  END AS job_type
FROM job_postings_fact
GROUP BY job_type;
SELECT COUNT(
    DISTINCT CASE
      WHEN job_work_from_home = TRUE THEN company_id
    END
  ) AS wfh_companies,
  COUNT(
    DISTINCT CASE
      WHEN job_work_from_home = FALSE THEN company_id
    END
  ) AS non_wfh_companies
FROM job_postings_fact;
--🟥 Problem 3
--Imp Question :)
SELECT job_id,
  job_title,
  CASE
    WHEN job_title ILIKE '%Senior%' THEN 'Senior'
    WHEN job_title ILIKE '%Manager%'
    or job_title ILIKE '%Lead%' THEN 'Lead/Manager'
    WHEN job_title ILIKE '%Junior%'
    or job_title ILIKE '%Entry%' THEN 'Junior/Entry'
    ELSE 'Not Specified'
  END AS experience_level,
  CASE
    WHEN job_work_from_home IS TRUE THEN 'Yes'
    ELSE 'No'
  END AS remote_option
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_id;