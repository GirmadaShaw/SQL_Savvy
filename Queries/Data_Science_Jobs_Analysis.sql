-- CREATE DATABASE DS_Jobs_Project
-- USE DS_Jobs_Project

-- Q1 
--  You are a Compensation analyst employed by a multinational corporation. 
--  Your Assignment is to Pinpoint Countries who give work fully remotely, for the title
--  managers’ Paying salaries Exceeding $90,000 USD

SELECT DISTINCT company_location
FROM jobs_data
WHERE work_setting = 'Remote' and salary_in_usd > 90000 and job_title like '%Manager%';



-- Q2
-- AS a remote work advocate Working for a progressive HR tech startup who
-- place their freshers’ clients IN large tech firms. you are tasked WITH Identifying
-- top 5 Country Having greatest count of large (company size) number of
-- companies.

SELECT DISTINCT company_location , COUNT(*) AS "Company_Count"
FROM jobs_data
WHERE experience_level = 'Entry-level'  and company_size = 'L'
GROUP BY company_location 
ORDER BY Company_Count DESC
LIMIT 5 ; 



-- Q3
-- Picture yourself AS a data scientist Working for a workforce management
-- platform. Your objective is to calculate the percentage of employees. Who
-- enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding
-- light ON the attractiveness of high-paying remote positions IN today's job
-- market.

set @total = ( select COUNT(*) from jobs_data ) ;
set @given_emp = ( select COUNT(*) from jobs_data where work_setting = 'Remote' and salary_in_usd > 100000 ); 
select round( (((@given_emp)/(@total)))  * 100 , 2 ) ;



-- Q4
-- Imagine you are a data analyst Working for a global recruitment agency. Your
-- Task is to identify the Locations where entry-level average salaries exceed the
-- average salary for that job title IN market for entry level, helping your agency
-- guide candidates towards lucrative opportunities.

select distinct company_location
from 
( select job_title , avg(salary_in_usd) as avg_salary 
from jobs_data 
where experience_level = 'Entry-level' 
group by job_title ) t 

inner join 

( select company_location , job_title , avg( salary_in_usd ) as avg_per_country
from jobs_data 
where experience_level = 'Entry-level'
group by job_title , company_location ) m 

where avg_per_country > avg_salary  ; 



-- Q5
-- You have been hired by a big HR Consultancy to look at how much people get
-- paid IN different Countries. Your job is to Find out for each job title which
-- Country pays the maximum average salary. This helps you to place your
-- candidates IN those countries.


select  m.job_title , m.company_location  , m.salary
from (select * , dense_rank() over ( partition by job_title order by salary desc ) as num 
	  from ( select job_title , company_location , max(salary_in_usd) as salary
		     from jobs_data 
             group by company_location , job_title 
            )t 
     )m 
where num = 1 ; 


-- Q6
-- AS a data-driven Business consultant, you've been hired by a multinational
-- corporation to analyze salary trends across different company Locations. Your
-- goal is to Pinpoint Locations WHERE the average salary Has consistently
-- Increased over the Past few years (Countries WHERE data is available for 3
-- years Only(present year and past two years) providing Insights into Locations
-- experiencing Sustained salary growth.


with param as(
	select * 
	from jobs_data 
	where company_location in (select company_location 
							   from  ( 
								select company_location , count( distinct work_year ) as "cnt" , avg( salary_in_usd ) as salary 
								from jobs_data 
								where work_year > (year( current_date() ) - 4 )
								group by company_location
								having cnt=3
                                     )t 
							  )
	         )

select company_location , 
MAX( CASE WHEN work_year = 2021 THEN salary END) AS avg_salary_2021,
MAX( CASE WHEN work_year = 2022 THEN salary END) AS avg_salary_2022,
MAX( CASE WHEN work_year = 2023 THEN salary END) AS avg_salary_2023

from (  select company_location , work_year , avg( salary_in_usd ) as salary 
		from param
		group by company_location , work_year 
	 )m group by company_location having avg_salary_2023 > avg_salary_2022 and avg_salary_2022 > avg_salary_2021   ;


-- Q7
-- Picture yourself AS a workforce strategist employed by a global HR tech
-- startup. Your Mission is to Determine the percentage of fully remote work for
-- each experience level IN 2021 and compare it WITH the corresponding figures
-- for 2023, Highlighting any significant Increases or decreases IN remote work
-- Adoption over the years.


select t.experience_level , t.percent_2021 , m.percent_2023 
from ( select t.experience_level , round( ((cnt)/(total))*100 , 2 )  as percent_2021 from ( select experience_level , count(*) as total 
											   from jobs_data 
                                               where work_year= 2021 
                                               group by experience_level ) t
                                               
                                               inner join 
                                               
                                              (select experience_level , count(*) as cnt 
                                               from jobs_data 
                                               where work_year= 2021 and work_setting='Remote' 
                                               group by experience_level )m on m.experience_level = t.experience_level )t
                                               
							inner join 
(select t.experience_level , round( ((cnt)/(total))*100 , 2 ) as percent_2023 from ( select experience_level , count(*) as total 
											   from jobs_data 
                                               where work_year= 2023 
                                               group by experience_level ) t
                                               
                                               inner join 
                                               
                                              (select experience_level , count(*) as cnt 
                                               from jobs_data 
                                               where work_year= 2023 and work_setting='Remote' 
                                               group by experience_level )m on m.experience_level = t.experience_level) m  on t.experience_level = m.experience_level ;
 

-- Q8
-- AS a Compensation specialist at a Fortune 500 company, you're tasked WITH
-- analyzing salary trends over time. Your objective is to calculate the average
-- salary increase percentage for each experience level and job title between the
-- years 2022 and 2023, helping the company stay competitive IN the talent
-- market.


select experience_level , job_title , round((((avg_salary2023)-(avg_salary2022))/avg_salary2022)*100,2) as percent_increase from ( select t.experience_level , t.job_title  , round(avg(t.avg_salary_2022),2) as avg_salary2022 , round(avg(m.avg_salary_2023),2) as avg_salary2023
from    ( select experience_level , job_title , avg(salary_in_usd) as avg_salary_2022 from jobs_data where work_year = 2022 
		group by experience_level , job_title  ) t
inner join 
		(select experience_level , job_title , avg(salary_in_usd) as avg_salary_2023 from jobs_data where work_year = 2023 
		group by experience_level , job_title ) m on t.experience_level = m.experience_level 
group by t.experience_level , t.job_title ) t ;


-- Q9
-- As a market researcher, your job is to Investigate the job market for a
-- company that analyzes workforce data. Your Task is to know how many
-- people were employed IN different types of companies AS per their size IN 2021.

select employment_type , company_size , count(*) "Employee Count"
from jobs_data
where work_year = 2021 
group by employment_type , company_size;



-- Q10
-- Imagine you are a talent Acquisition specialist Working for an International
-- recruitment agency. Your Task is to identify the top 3 job titles that command
-- the highest average salary Among part-time Positions IN the year 2023.
-- However, you are Only Interested IN Countries WHERE there are more than
-- 50 employees, Ensuring a robust sample size for your analysis.

with param as ( 
select job_title ,  salary_in_usd , employment_type  from jobs_data 
where company_location in (select company_location 
						   from (select company_location , count(*) as cnt from jobs_data 
								 where work_year = 2023 group by company_location having cnt>50
								)t
	                      )
			  )

select job_title , round(avg(salary_in_usd),2) as avg_salary from param where employment_type = 'Part-time' 
group by job_title  order by avg_salary desc ;
         
         
-- Q11
-- As a database analyst you have been assigned the task to Select Countries
-- where average mid-level salary is higher than overall mid-level salary for the
-- year 2023.

set @mid_level_salary = ( select avg(salary_in_usd) from jobs_data where experience_level = 'Mid-level'); 

select distinct company_location , round(avg(salary_in_usd),2) as salary 
from jobs_data
where work_year = 2023
group by company_location 
having salary > @mid_level_salary ; 


-- Q12
-- As a database analyst you have been assigned the task to Identify the
-- company locations with the highest and lowest average salary for senior-level
-- (SE) employees in 2023.

select * from  (select company_location , round(avg(salary_in_usd),2) as highest_avg_salary 
	from jobs_data 
	where work_year = 2023 and experience_level = 'Senior' 
	group by company_location 
	order by highest_avg_salary desc limit 1 )t

inner join

	(select company_location , round(avg(salary_in_usd),2) as lowest_avg_salary 
	from jobs_data 
	where work_year = 2023 and experience_level = 'Senior' 
	group by company_location 
	order by lowest_avg_salary limit 1 )m  ;
 


-- Q13
-- You're a Financial analyst Working for a leading HR Consultancy, and your
-- Task is to Assess the annual salary growth rate for various job titles. By
-- Calculating the percentage Increase IN salary FROM previous year to this
-- year, you aim to provide valuable Insights Into salary trends WITHIN different
-- job roles.      
	
select t.job_title , salary_2022 , salary_2023 , round(((salary_2023-salary_2022)/salary_2022)*100,2) as percent_incr      from	( select job_title , round( avg( salary_in_usd ) , 2 ) as salary_2022 from jobs_data
	where work_year = 2022
	group by job_title ) t
inner join
	( select job_title , round( avg( salary_in_usd ) , 2 ) as salary_2023 from jobs_data
	where work_year = 2023
	group by job_title ) m on t.job_title = m.job_title ; 


-- Q14
-- You've been hired by a global HR Consultancy to identify Countries
-- experiencing significant salary growth for entry-level roles. Your task is to list
-- the top three Countries with the highest salary growth rate FROM 2020 to
-- 2023, Considering Only companies with more than 50 employees, helping
-- multinational Corporations identify Emerging talent markets.


with param as (
select company_location , work_year, salary_in_usd from jobs_data where company_location in ( select company_location 
													from (select company_location , count(*) as cnt 
															from jobs_data  
															group by company_location having cnt>50 
														)t
										          ) and experience_level = 'Entry-level' 
                                                  
			 )
             
select company_location , round( ((year_2023-year_2020)/year_2020)*100,2) as percent_incr from ( select company_location ,
MAX( CASE WHEN work_year = 2020 THEN average_sal  END ) AS year_2020,
MAX( CASE WHEN work_year = 2021 THEN average_sal END ) AS year_2021,
MAX( CASE WHEN work_year = 2022 THEN average_sal END ) AS year_2022,
MAX( CASE WHEN work_year = 2023 THEN average_sal END ) AS year_2023
from ( select company_location , work_year, round(avg(salary_in_usd),2) as average_sal from param 
		group by company_location , work_year  )t
group by company_location )m order by percent_incr desc  limit 3 ; 
        
	
    
    
-- Q15
-- You are a researcher and you have been assigned the task to Find the year
-- with the highest average salary for each job title.

select work_year , job_title , max(avg_salary) as Max_Salary from (select * , dense_rank() over ( partition by job_title order by avg_salary ) as num
from  (select work_year , job_title ,  round(avg( salary_in_usd ),2) as avg_salary from jobs_data 
			group by  work_year , job_title )t ) m
where num = 1 group by work_year , job_title order by work_year desc  ; 


-- Q16
-- You have been hired by a market research agency where you been assigned
-- the task to show the percentage of different employment type (full time, part
-- time) in Different job roles, in the format where each row will be job title, each
-- column will be type of employment type and cell value for that row and column
-- will show the % value.

set @total_emp = ( select count(*) from jobs_data ); 
select job_title, 
MAX( CASE WHEN employment_type = 'Full-time' THEN men END ) AS FullTime_Emp,
MAX( CASE WHEN employment_type = 'Part-time' THEN men END ) AS PartTime_Emp,
MAX( CASE WHEN employment_type = 'Contract' THEN men END ) AS Contract_Emp,
MAX( CASE WHEN employment_type = 'Freelance' THEN men END ) AS Freelance_Emp 
from ( select job_title ,employment_type , round((count(*)/(@total_emp))*100,2) as men 
			from jobs_data group by job_title , employment_type )t
group by job_title ; 

