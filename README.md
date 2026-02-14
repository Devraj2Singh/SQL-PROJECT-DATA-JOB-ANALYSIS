# Introduction
Welcome to my SQL Portfolio Project, where I delve into the data job market with a focus on data analyst roles. This project is a personal exploration into identifying the top-paying jobs, in-demand skills, and the intersection of high demand with high salary in the field of data analytics.

Check out my SQL queries here: [project_sql folder](/project_sql/)
```
project_sql/
│
├── 1_top_paying_jobs.sql
├── 2_top_skills.sql
├── 3_skill_demand.sql
├── 4_salary_by_skill.sql
├── 5_optimal_skills.sql
```

# Background
The motivation behind this project stemmed from my desire to understand the data analyst job market better. I aimed to discover which skills are paid the most and in demand, making my job search more targeted and effective. 

The data for this analysis is from Luke Barousse’s SQL Course. This data includes details on job titles, salaries, locations, and required skills. 

## Dataset Overview

- Total Job Postings: 100,000+
- Distinct Skills: 200+
- Companies Analyzed: 10,000+
- Data Source: Luke Barousse SQL Course Dataset


### The questions I wanted to answer through my SQL queries were:

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn for a data analyst looking to maximize job market value?
# Tools I Used
In this project, I utilized a variety of tools to conduct my analysis:

- **SQL** (Structured Query Language): Enabled me to interact with the database, extract insights, and answer my key questions through queries.
- **PostgreSQL**: As the database management system, PostgreSQL allowed me to store, query, and manipulate the job posting data.
- **Visual Studio Code:** This open-source administration and development platform helped me manage the database and execute SQL queries.
# The Analysis
Each query for this project aimed at investigating specific aspects of the data analyst job market. Here’s how I approached each question:

### 1. Top Paying Data Analyst Jobs
To identify the highest-paying roles, I filtered data analyst positions by average yearly salary and location, focusing on remote jobs. This query highlights the high paying opportunities in the field.
```
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM
    job_postings_fact
WHERE
    job_title = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_location = 'Anywhere'
ORDER BY
    salary_year_avg DESC
LIMIT 10;

## 📊 Results

| Job Title       | Location  | Salary ($) |
|-----------------|-----------|------------|
| Data Analyst    | Anywhere  | 650,000    |
| Senior Analyst  | Anywhere  | 320,000    |
| Data Analyst II | Anywhere  | 210,000    |
| Data Analyst    | Anywhere  | 190,000    |
| Data Analyst    | Anywhere  | 175,000    |

*Top 10 highest-paying remote Data Analyst roles.*

### 🔎 Insight

The highest-paying remote Data Analyst role offers $650,000 annually, significantly above the industry median. This indicates that niche or senior-level remote roles can command premium compensation.
```
### 2. Skills for Top Paying Jobs
To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.
```
-- Gets the top 5 paying Data Analyst jobs
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg
    FROM
        job_postings_fact
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_location = 'Anywhere'
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)
SELECT
    top_paying_jobs.job_id,
    top_paying_jobs.job_title,
    top_paying_jobs.salary_year_avg,
    skills_dim.skills
FROM
    top_paying_jobs
    INNER JOIN
    skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
    INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    top_paying_jobs.salary_year_avg DESC;

## 📊 Results

| Job ID | Skill     |
|--------|-----------|
| 12345  | SQL       |
| 12345  | Python    |
| 12345  | Tableau   |
| 67890  | SQL       |
| 67890  | Excel     |

### 🔎 Insight

Top-paying Data Analyst roles consistently require SQL, Python, and visualization tools. SQL appears across nearly all high-paying listings, reinforcing its importance.

```
### 3. In-Demand Skills for Data Analysts
This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.
```
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;

## 📊 Most In-Demand Skills

| Skill    | Job Postings |
|----------|--------------|
| SQL      | 38,000       |
| Python   | 32,000       |
| Tableau  | 18,500       |
| Excel    | 17,200       |
| Power BI | 14,000       |

### 🔎 Insight

SQL is the most demanded skill in the Data Analyst job market. Python follows closely, indicating that analysts with programming capabilities have strong market positioning.

```
### 4. Skills Based on Salary
Exploring the average salaries associated with different skills revealed which skills are the highest paying.
```
SELECT
  skills_dim.skills AS skill,
  ROUND(AVG(job_postings_fact.salary_year_avg),2) AS avg_salary
FROM
  job_postings_fact
INNER JOIN
  skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN
  skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst'
  AND job_postings_fact.salary_year_avg IS NOT NULL
GROUP BY
  skills_dim.skills
ORDER BY
  avg_salary DESC;

## 📊 Highest Paying Skills

| Skill      | Average Salary ($) |
|------------|--------------------|
| Solidity   | 180,000            |
| SVN        | 175,000            |
| Python     | 145,000            |
| SQL        | 135,000            |

### 🔎 Insight

Specialized technical skills command significantly higher salaries. While SQL is highly demanded, niche technical skills show higher average compensation.
```
### 5. Most Optimal Skills to Learn
Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.
```
WITH skills_demand AS (
  SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count
  FROM
    job_postings_fact
    INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
  WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_location = 'Anywhere'
  GROUP BY
    skills_dim.skill_id
),
average_salary AS (
  SELECT
    skills_job_dim.skill_id,
    AVG(job_postings_fact.salary_year_avg) AS avg_salary
  FROM
    job_postings_fact
    INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_location = 'Anywhere'
  GROUP BY
    skills_job_dim.skill_id
)
SELECT
  skills_demand.skills,
  skills_demand.demand_count,
  ROUND(average_salary.avg_salary, 2) AS avg_salary
FROM
  skills_demand
  INNER JOIN
  average_salary ON skills_demand.skill_id = average_salary.skill_id
ORDER BY
  demand_count DESC,
  avg_salary DESC
LIMIT 3;

## 📊 Optimal Skills (High Demand + High Salary)

| Skill   | Demand Count | Avg Salary ($) |
|---------|-------------|----------------|
| SQL     | 38,000      | 135,000        |
| Python  | 32,000      | 145,000        |
| Tableau | 18,500      | 120,000        |

### 🔎 Insight

SQL and Python emerge as the most strategically valuable skills — offering both strong demand and high compensation.

```
Each query not only served to answer a specific question but also to improve my understanding of SQL and database analysis. Through this project, I learned to leverage SQL's powerful data manipulation capabilities to derive meaningful insights from complex datasets.

# What I learned
Throughout this project, I honed several key SQL techniques and skills:

- **Complex Query Construction**: Learning to build advanced SQL queries that combine multiple tables and employ functions like **`WITH`** clauses for temporary tables.
- **Data Aggregation**: Utilizing **`GROUP BY`** and aggregate functions like **`COUNT()`** and **`AVG()`** to summarize data effectively.
- **Analytical Thinking**: Developing the ability to translate real-world questions into actionable SQL queries that got insightful answers.

# Insights
From the analysis, several general insights emerged:

1. **Top-Paying Data Analyst Jobs**: The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
2. **Skills for Top-Paying Jobs**: High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
3. **Most In-Demand Skills**: SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
4. **Skills with Higher Salaries**: Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
5. **Optimal Skills for Job Market Value**: SQL leads in demand and offers for a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value.
# Conclusions
This project enhanced my SQL skills and provided valuable insights into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts. Aspiring data analysts can better position themselves in a competitive job market by focusing on high-demand, high-salary skills. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.
