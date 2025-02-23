select * from walmart;
---------------------------------------
--drop table walmart;
--Total Transaction
select count(*) from walmart;
---------------------------------------
--distinct Payment Method
Select distinct payment_method from walmart;
--------------------------------------------------------

--Total payment method
select payment_method, count(*)
   from walmart
   group by payment_method;
------------------------------------------------------

--Maximum and minimum quantity
select max(quantity) from walmart;
select min(quantity) from walmart;
-----------------------------------------------------

-- Buisness Problem
--Q1) Find different payment method and no of transactions, no of quantity sold?
select payment_method,
       count(*) as no_of_transactions,
       sum(quantity) as no_of_qty
from walmart
group by payment_method;

--------------------------------------------------------------
-- Q2) Identify the highest rated category in each branch displaying the branch, category
--     Avg rating
Select branch,
       category,
       Avg(rating) as avg_rating,
	   RANK() OVER (PARTITION by branch Order by  Avg(rating) DESC) as rank  
from walmart
group by 1, 2;

--For rank =1 Highest branch
select * from
	(Select branch,
       category,
       Avg(rating) as avg_rating,
	   RANK() OVER (PARTITION by branch Order by  Avg(rating) DESC) as rank  
from walmart
group by 1, 2)
where rank=1;

---------------------------------------------------------------------------------
-- Q3) Identify the busiest day for each branch based on the no of transactions?
--converted date from text tyoe to date type
Select date,
	   TO_DATE(date, 'DD/MM/YY') as formated_date
	from walmart;

-- to get day name

Select date,
	   TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'DAY') as day_name
	from walmart;

--busiest day in a branch based on no of transactions
select * from(
	Select branch,
		   TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'DAY') as day_name,
		   count(*) as no_of_transaction,
		   RANK() OVER (PARTITION by branch Order by Count(* )DESC) as rank
	from walmart
	group by 1, 2)
where rank=1;
-----------------------------------------------------------------------------------------

--Q4) Calculate the total quantity of items sold per payment method. List payment method
--    and total quantity

select payment_method,
       sum(quantity) as no_of_qty
from walmart
group by payment_method;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q5) Determine the Average, minimum and maximum rating of Category for each city?
--   List the city, avg_rating, min_rating and max_rating

Select city,
       category,
       MAX(rating) as max_rating,
       MIN(rating) as min_rating,
       AVG(rating) as avg_rating
from walmart
group by 1,2;
---------------------------------------------------------------------------------------------------------------------------

-- Q6) Calculate the total profit for each category by considering total profit as
--     (unit_price * quantity * profit_margin).

--    List category and total_profit, ordered from highest to lowest.

Select category,
       SUM(total) as Total_Revenue,
       SUM(total * profit_margin) as Profit
from walmart
Group by 1;

--------------------------------------------------------------------------------------------------------------------------
-- Q7) Determine the most common payment method for each branch. Display branch and 
--     preffered payment_method
With cte
AS
	(select payment_method,
	       branch,
	       Count(*) as no_of_trans,
	       RANK() OVER (PARTITION by branch Order By Count(*) DESC) as rank
	from walmart
	group by 1, 2)
Select * from cte	
where rank=1

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q8) Categorise sales into 3 groups Morning, Afternoon, Evening
--   Find out each of the shifts and no of invoices

--Convert time from text type to time type	
select 
time :: time
from walmart

--categorising into 3 shift

select  branch,
      CASE 
          WHEN EXTRACT (HOUR FROM (time::time)) < 12 THEN 'Morning'
          WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
          ELSE 'Evening'
      END day_time,
	  Count(*) as no_of_transaction
from walmart
group by 1, 2
Order by 1, 3 DESC
----------------------------------------------------------------------------------------------------------------------------------------

-- Q9) Identify 5 branch with highest decrease ratio in revenue compare to last year 
--     (current year 2023 last year 2022)

-- revenue_dec_ratio = last_yr_rev - curr_yr_rev/lst_yr_rev * 100

-- sales 2022
WITH revenue_2022 AS (
    SELECT branch,
           SUM(total) AS Revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY 1
),
revenue_2023 AS (
    SELECT branch,
           SUM(total) AS Revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as curr_year_revenue,
   ROUND((ls.revenue - cs.revenue)::numeric/ 
		 ls.revenue::numeric * 100 , 
         2) as revenue_dec_ratio
	FROM revenue_2022 AS ls
	JOIN revenue_2023 AS cs
	ON ls.branch = cs.branch
	Where ls.revenue > cs.revenue
    order by 4 DESC
    LIMIT 5;
