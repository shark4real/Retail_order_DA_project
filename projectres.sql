select * from orders

-- find top 10 highest revenue generating products

select  product_id,sum(sale_price) as sales
from orders
group by product_id
order by sales desc
limit 10;


-- find top 5 highest  selling products in each region 
with cte as ( 
select region,product_id,sum(sale_price) as sales
from orders
group by region, product_id)
select *from (
select * 
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn <=5

-- find month over month growth comparision for 2022 and 2023 sales eg: jan 2022 vs 2023
with cte as(
select extract(year from order_date) as order_year,extract(month from order_date) as order_month,
sum(sale_price) as sales
from orders
group by order_year, order_month
--order by order_year, order_month
)
select order_month
,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

-- for each category which month had the highest sales
with cte as (
select category, to_char(order_date, 'YYYYMM') as order_year_month,
sum(sale_price) as sales
from orders
group by category,to_char(order_date, 'YYYYMM')
order by category,to_char(order_date, 'YYYYMM')
)
select * from(
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1


--which sub category had the highest growth (percentage) by profit in 2023 compare to 2022

with cte as(
select sub_category ,extract(year from order_date) as order_year,
sum(sale_price) as sales
from orders
group by sub_category,order_year
)
,cte2 as (
select sub_category
,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/(sales_2022) as answer
from cte2
order by answer desc
limit 1





