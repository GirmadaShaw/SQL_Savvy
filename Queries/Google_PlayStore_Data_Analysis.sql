-- USE ds_jobs_project;
-- truncate table playstore ; 

-- load data infile "C:/Users/91770/Desktop/Important Work/HTML/BUILD/SQL_Projects/Datasets/playstore.csv" 
-- into table playstore 
-- fields terminated by ','
-- optionally enclosed by '"'
-- lines terminated by '\r\n'
-- ignore 1 rows ;   

-- select count(*) from playstore ; 




-- Q1
-- You're working as a market analyst for a mobile app development
-- company. Your task is to identify the most promising categories
-- (TOP 5) for launching new free apps based on their average
-- ratings.

select category , round(avg(Rating),2) as avg_rating 
from playstore 
group by category 
order by avg_rating desc 
limit 5 ;


-- Q2
-- As a business strategist for a mobile app company, your objective
-- is to pinpoint the three categories that generate the most revenue
-- from paid apps. This calculation is based on the product of the app
-- price and its number of installations. 

select distinct app, category , ( Installs * Price ) as cost 
from playstore 
where Type = 'Paid' 
order by cost desc 
limit 3 ;


-- Q3
-- As a data analyst for a gaming company, you're tasked with
-- calculating the percentage of games within each category. This
-- information will help the company understand the distribution of
-- gaming apps across different categories.

set @total = (select count(App) from playstore  ) ; 
select Category,  round((cnt/@total)*100,2) as Percentage   
from (select Category , count(*) as cnt 
		from playstore 
		group by Category ) t ;


-- Q4
-- As a data analyst at a mobile app-focused market research firm
-- you’ll recommend whether the company should develop paid or
-- free apps for each category based on the ratings of that category.


select t.Category , free_avg_rating , paid_avg_rating , if ( free_avg_rating < paid_avg_rating , "Paid Apps" , "Free Apps" ) as develop 
from (select Category , round( avg( Rating ) , 2 ) as free_avg_rating from playstore where Type = 'Free' group by Category ) t 
inner join 
(select Category , round( avg( Rating ) , 2 ) as paid_avg_rating from playstore where Type = 'Paid' group by Category) m 
on t.Category = m.Category ; 


-- Q5
-- Suppose you're a database administrator your databases have
-- been hacked and hackers are changing price of certain apps on
-- the database, it is taking long for IT team to neutralize the hack,
-- however you as a responsible manager don’t want your data to be
-- changed, do some measure where the changes in price can be
-- recorded as you can’t stop hackers from making changes.

-- Q6. 
-- Your IT team have neutralized the threat; however, hackers have
-- made some changes in the prices, but because of your measure
-- you have noted the changes, now you want correct data to be
-- inserted into the database again.






-- Q7
-- As a data person you are assigned the task of investigating the
-- correlation between two numeric factors: app ratings and the
-- quantity of reviews.


set @avg_rating = ( select round(avg( Rating ),2) from playstore ) ; 
set @avg_qor = ( select round(avg( Reviews ),2) from playstore ) ; 

select (4)*4;

select round(sum(numr)/(sqrt( sum(SS_Rating) * sum(SS_Reviews))),2 ) as Correlation  
from (select (Rating - @avg_rating) * (Rating - @avg_qor) as numr, SS_Rating , SS_Reviews  
		from (select App , Rating ,  Reviews , round((Rating - @avg_rating)*(Rating - @avg_rating) , 2) as SS_Rating , round((Reviews - @avg_qor)*(Reviews - @avg_qor) , 2) as SS_Reviews 
from playstore )t
)r; 






