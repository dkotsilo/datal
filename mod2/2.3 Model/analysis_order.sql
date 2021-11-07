-- Totat sales

select sum(sales) as total_sales 
from orders o 


-- Total profit

select sum(profit) as total_profit
from orders o 


-- Total ratio

select sum(sales) / sum(profit) as total_ratio
from orders o 

-- Average discount 

select avg(discount) as avg_discount
from orders o 

-- Sales per Customer
select sum(sales) / count(distinct customer_id) as sales_per_customer
from orders o 


-- Profit per order 
select sum(profit) / count(distinct order_id) as profit_per_order
from orders o 


-- Sales by product Category over time

select category, sum(sales) as total_sales
from orders o 
group by category 
order by total_sales desc


-- Sales per Region 

select region, sum(sales) as total_sales
from orders o 
group by region 



-- Customer ranking 
select 
	customer_name, sum(sales) as total_sales, sum(profit) as total_profit
from orders o 
group by customer_name 
order by total_sales desc


--- Monthly sales by segment 
select 
	segment,
--	date_trunc('month', order_date) as month_year,
	extract(month from order_date) as month_year,
	sum(sales) as total_sales,
	sum(profit) as total_profit, 
	avg(discount) as discount
from orders o 
group by segment, month_year
order by month_year, total_profit desc


--- Monthly sales by product category
select 
	category,
--	date_trunc('month', order_date) as month_year,
	extract(month from order_date) as month_year,
	sum(sales) as total_sales,
	sum(profit) as total_profit, 
	avg(discount) as discount
from orders o 
group by category, month_year
order by month_year, total_sales desc









