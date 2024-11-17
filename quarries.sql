-- created Database
create database retail_sales_db;

-- table created
create table retail_sales(transactions_id int primary key,
	sale_date date,
	sale_time time,
	customer_id int,
	gender varchar(15),
	age int,
	category varchar(15),
	quantity int,
	price_per_unit float,
	cogs float,
	total_sale float    
);
 
SELECT * FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

 
-- 1. What is the total revenue generated across all transactions?
SELECT 
   sum(total_sale) as revenue
FROM
    retail_sales;
    
-- 2 Calculate Net profit by year
SELECT 
    YEAR(sale_date) AS year,
    ROUND(SUM(total_sale - cogs), 2) AS profit_by_year
FROM
    retail_sales
GROUP BY 1
ORDER BY 2 DESC;  

-- 3 Calculate No.of unit sold by year 
 SELECT 
    YEAR(sale_date) AS year, COUNT(transactions_id) AS unit_sold
FROM
    retail_sales
GROUP BY 1
ORDER BY 2 DESC;  
 
-- 4. How many units of each category were sold?
SELECT 
    category,
    SUM(quantity) AS unit_sold,
    SUM(total_sale) AS revenue_of_Each_category
FROM
    retail_sales
GROUP BY category order by 2  desc;  

-- 5. What is the average sales amount per transaction?
with avg_sales as (SELECT 
 transactions_id,
    avg(quantity * price_per_unit) AS avg_sales
FROM
    retail_sales
group by transactions_id)   
SELECT 
    ROUND(AVG(avg_sales), 2) AS avg_sales_each_transaction
FROM
    avg_sales;

-- avg_sales return avg sales fro each transaction and then we find avg_sales_each_transaction  

 
-- 6. Which category generated the highest total revenue?
SELECT 
    category, SUM(total_sale) AS revenue
FROM
    retail_sales
GROUP BY category
ORDER BY 2 DESC;

-- 7. What is the total profit (total sale - COGS) for each category?
SELECT 
    category,
    ROUND(SUM(quantity * price_per_unit) - SUM(cogs),
            2) AS total_profit
FROM
    retail_sales
GROUP BY category
ORDER BY 2 DESC; 

-- 8. How many transactions were made by male and female customers?
SELECT 
    gender, COUNT(transactions_id) AS transactions_by_gender
FROM
    retail_sales
GROUP BY gender;

-- 9. What is the distribution of sales by customer age groups (e.g., 18-25, 26-35, etc.)?
SELECT 
    CASE
        WHEN age >= 18 AND age <= 25 THEN '18-25'
        WHEN age > 25 AND age <= 35 THEN '26-35'
        WHEN age > 35 AND age <= 45 THEN '36-45'
        WHEN age > 45 AND age <= 55 THEN '46-55'
        ELSE '55+'
    END AS age_group,
    SUM(total_sale) AS sales
FROM
    retail_sales
GROUP BY 1
ORDER BY 2 DESC
; 
 

-- 10. Which day of the week had the highest total sales?
SELECT 
    YEAR(sale_date),
    MONTH(sale_date),
    DAYOFWEEK(sale_date) AS dayOFWEEk,
    SUM(quantity * price_per_unit) total_sales
FROM
    retail_sales
GROUP BY 1 , 2 , 3
ORDER BY 4 DESC;
-- 2022/10 second week (2) as total sales of 16675 wich is highest Amount
 
 
-- 11. What is the hourly distribution of total sales?
with hourly_distribution_2022 as (select  hour(sale_time) as sales_hour, count(quantity ) as sales_count ,
sum(price_per_unit *quantity) as hourly_sales  from retail_sales
where year(sale_date) =2022
group by 1),

hourly_distribution_2023 as (select  hour(sale_time) as sales_hour, count(quantity ) as sales_count ,
sum(price_per_unit *quantity) as hourly_sales  from retail_sales
where year(sale_date) =2023
group by 1 ),

diffrence as ( 
select hr22.sales_hour, hr22.hourly_sales as hourly_sales22, hr23.hourly_sales as hourly_sales23
 from hourly_distribution_2022 hr22 join hourly_distribution_2023 hr23
on hr22.sales_hour =  hr23.sales_hour)
SELECT 
    *, (hourly_sales23 - hourly_sales22) AS diffrence_sales
FROM
    diffrence
ORDER BY diffrence_sales DESC;


-- 12. Which customer ID has the highest total purchase value?
SELECT 
    customer_id, SUM(total_sale) AS total_purchase
FROM
    retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 13  Monthly Sales Trend
SELECT 
    MONTH(sale_date) AS Month,
    SUM(CASE
        WHEN YEAR(sale_date) = 2022 THEN quantity * price_per_unit
        ELSE 0
    END) AS Sales_2022,
    SUM(CASE
        WHEN YEAR(sale_date) = 2023 THEN quantity * price_per_unit
        ELSE 0
    END) AS Sales_2023
FROM
    retail_sales
GROUP BY Month
ORDER BY Month;

-- 14. Find the average age of customers purchasing from specific categories ('Clothing')
SELECT 
    ROUND(AVG(age), 1) AS avgAge_Clothing
FROM
    retail_sales
WHERE
    category = 'Clothing'; -- 41.9


-- 15. Find transactions with total sales greater than 1000.  
select * from retail_sales where total_sale > 1000 ;


-- 16. Find the total number of transactions made by each gender in each category.  
select gender,category,count(transactions_id) as total_transaction from retail_sales
group by 2,1 order by 1,3;


-- 17. Calculate the average sale for each month and determine the best-selling month in each year. 
select year, month
 from (
select year(sale_date) as year,
month(sale_date) as month,
round(avg(total_sale),2) as avg_total_sale,
rank() over(partition by year(sale_date) order by avg(total_sale) desc) as rank_
from retail_sales
group by 1,2  order by 1) as t1
where rank_=1;


-- 18. Find the top 5 customers based on the highest total sales.
select customer_id , sum(total_sale) as total_Sale_by_customers
 from retail_sales
 group by 1 
 order by 2 
 desc limit 5;

-- 19. Find the number of unique customers who purchased items from each category.
select  category, COUNT(DISTINCT customer_id) AS dis_customer_id from retail_sales 
group by 1;


-- 20. Analyze sales by shifts (Morning, Afternoon, Evening).
 WITH hourly_sale AS (
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift