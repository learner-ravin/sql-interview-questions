-- 1.  Find duplicate records in a table
select emp_id , count(*) as counts from employees
		group by emp_id
        having counts > 1;

-- 2. Retrieve the second highest salary from the Employee table
select max(salary) as sec_highest_salary from employees
	where salary < (select max(salary) from employees);

-- 3. Find employees without department
select * from employees
	where dept is null;

-- 4. Calculate the total revenue per product
select product_id, sum(quantity * amount) as total_revenue
from orders
	group by product_id;

-- 5. Get the top 3 highest-paid employees.
-- 1
select * from (
select *,
	dense_rank() over(order by salary desc) as rnk
    from employees) t
    where rnk < 4;

-- 2
select * from employees
	order by salary desc limit 3;


-- 6. Customers who made biggest purchases from each region
with cte as 
(select  c.customer_id, c.customer_name, t.total_purchase, c.region ,
	row_number() over(partition by region order by total_purchase desc) as rn 
from (select customer_id, sum(amount) as total_purchase
		from orders group by customer_id)  t
	join customers c
    on c.customer_id = t.customer_id)
    select * from cte
    where rn = 1;
    
-- 7. Show the count of orders per customer.
select customer_id, count(*) as order_counts from orders
		group by customer_id
        order by customer_id;

-- 8. Retrieve all employees who joined in 2023.
select * from employees
	where join_date >='2023-01-01'
    and     join_date <= '2023-12-31';

-- 9. Calculate the average order value per customer.
select customer_id, 
	sum(amount) as total_amount,
    count(*) as total_orders,
    round(sum(amount) /count(*),2)  as avg_order_value
    from orders
    group by customer_id;

-- 10. Get the latest order placed by each customer.
select * from 
(select *,
	row_number() over(partition by customer_id order by order_date desc)  as rnk
    from orders) t
    where rnk = 1;

-- 11. Find products that were never sold.
select p.product_id, p.product_name from products p
		left join orders o
        on p.product_id = o.product_id
        where o.order_id is null;

-- 12. Identify the most selling product.
select product_id, sum(quantity) as total_sold
		from orders
        group by product_id
        order by total_sold desc limit 1;
        
-- 13. Get the total revenue and the number of orders per region.
select region ,
			sum(amount) as total_revenue,
            count(*) as total_orders
			from orders o 
		join customers c 
        on o.customer_id = c.customer_id
        group by region;

-- 14. Count how many customers placed more than 20 orders.
select count(*) as customer_counts 
from
	(select customer_id, count(*) as total_orders from orders
		group by customer_id
        having total_orders >20) t;
        
-- 15. Retrieve customers with orders above the average order value.
select * from orders
	where amount > (select avg(amount) from orders);
    
-- 16. Find all employees joined on weekends.
select * from employees
	where dayname(join_date) in ("Saturday", "Sunday");

-- 17. Find all employees from Marketing department hired on weekends.
select * from employees
		where dayofweek(join_date) in (1,7)
			and dept = "Marketing";

-- 18. Get monthly sales revenue and order count.
select  date_format(order_date, "%Y-%m") as year__month,
		sum(amount) as total_sale,
		count(*) as total_order
        from orders
        group by date_format(order_date, "%Y-%m")
        order by year__month;

-- 19. Rank employees by salary within each department.
select *,
	dense_rank() over(partition by dept order by salary desc) as rnk
	from employees;

-- 20. Find customers who placed orders every month in 2025.
select customer_id, 
	count(distinct month(order_date)) as months_counts
		from orders
		where order_date >= '2025-01-01'
		    and order_date <'2026-01-01'
        group by customer_id
        having months_counts = 12;

-- 21. Find moving average of sales over the last 3 days.
with cte as 
(select order_date, sum(amount) as day_total
    from orders
    group by order_date)
    select order_date, 
			  day_total,
              avg(day_total) over(order by order_date rows between 2 preceding and current row) as moving_avg
              from cte;

-- 22. Identify the first and last order date for each customer.
select customer_id,
		min(order_date) as first_order,
        max(order_date) as last_order 
        from orders
        group by customer_id;

-- 23. Show product sales distribution (percent of total revenue).
select product_id, sum(amount) as totals,
	100.0 * sum(amount) / (select sum(amount) from orders) as percentage
	from orders
		group by product_id;

-- 24. Retrieve customers who made consecutive purchases (2 Days).
select * from (
select customer_id,
		order_date,
        lag(order_date) over(partition by customer_id order by order_date) as prev_order_date
        from orders) t
        where datediff(order_date, prev_order_date) = 1;

-- 25. Find churned customers (no orders in the last 3 months).
	select customer_id, max(order_date) as last_order from
			orders group by customer_id
            having last_order < date_sub("2026-03-05", interval 3 month);
		
-- 26. Calculate cumulative revenue by day.
with cte as (
select order_date, sum(amount) as   day_revenue 
from orders
		group by order_date)
        select *,
			sum(day_revenue) over(order by order_date) as cum_sum from cte;

-- 27. Identify top-performing departments by average salary.
select dept, round(avg(salary),2) avg_salary from employees
		group by dept
        order by avg_salary desc
        limit 5;

-- 28. Find customers who ordered more than the average number of orders per customer
select customer_id, count(*)  as no_of_orders from orders
		group by customer_id
        having count(*) > (select count(order_id) / count( distinct(customer_id)) from orders);

-- 29. Calculate revenue generated from new customers (first-time orders).
-- 1
select sum(amount) as revenue from orders o
	where order_date = (
					select min(order_date) from orders 
                    where o.customer_id = customer_id);

-- 2
select sum(amount) as revenue from (
select * ,
		row_number() over(partition by customer_id order by order_date asc) as rw
        from orders) t
        where rw = 1;
        
-- 30. Find the percentage of employees in each department.
select dept, 
	count(*) as no_of_employyes,
	100.0 * count(*) / sum(count(*)) over()  as percentage
	from employees
	group by dept;

