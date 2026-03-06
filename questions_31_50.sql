-- 31. Retrieve the maximum salary difference within each department.
select dept, 
		max(salary) as max_salary,
        min(salary) as min_salary,
        max(salary) - min(salary) as max_salary_difference
        from employees
        group by dept;

	-- 32. Find products that contribute to 80% of the revenue (Pareto Principle).
    with product_revenue as 
    (select product_id, sum(amount) as revenue
			from orders
            group by product_id),
		cum_revenue_t as
		(select *,
			sum(revenue) over(order by revenue desc) as cum_revenue,
            sum(revenue) over() as total_revenue
		from product_revenue)
	select product_id, revenue
    from cum_revenue_t
    where cum_revenue / total_revenue <= 0.8;

-- 33. Calculate average time between two purchases for each customer.
with cte as 
(select customer_id, order_date,
	lag(order_date) over(partition by customer_id order by 	order_date) as prev_date
 from orders)
 select customer_id, avg(datediff(order_date, prev_date)) as avg_time_gap 
		from cte
        group by customer_id;
 
-- 34. Show last purchase for each customer along with order amount.
with cte as (
select customer_id, order_date, amount,
		row_number() over(partition by customer_id order by order_date desc) as rn
        from orders)
	select customer_id, order_date, amount from cte where rn = 1;

-- 35. Calculate month-over-month growth in revenue.
with cte as (
select year_month_,
	revenue,
    lag(revenue) over(order by year_month_) as prev_month
    from (
select date_format(order_date, "%Y-%m") as year_month_,
		sum(amount) as revenue from orders
        group by date_format(order_date, "%Y-%m")) t)
        select *,
        round(100.0 * (revenue - prev_month) / prev_month,2) as mom_growth
        from cte;

-- 36. Detect customers whose purchase amount is higher than their historical 90th percentile.
select * from 
(select *,
		cume_dist() over(partition by customer_id order by amount) as cd
        from orders) t
	where cd > 0.9;

-- 37. Retrieve the longest gap between orders for each customer.
select customer_id, max(datediff(order_date,prev_order)) as longest_gap from (
select customer_id, order_date ,
		lag(order_date) over(partition by customer_id order by order_date asc) as prev_order
from orders) t
	where prev_order is not null
	group by customer_id;

-- 38. Identify customers with revenue below the 10th percentile.
select * from 
(select *, 
		percent_rank() over(order by revenue) as pct_rank from
(select customer_id, sum(amount) as revenue 
		from orders 
        group by customer_id) t) tt
        where pct_rank < 0.1;

-- 39. Find the product that generated the highest total sales revenue and the product that was purchased the most times, for each category.
with cte as 
(select p.product_id, p.product_name, product_bought, total_revenue, category ,
		dense_rank() over(partition by category order by product_bought desc) as bought_rank,
        dense_rank() over(partition by category order by total_revenue desc) as revenue_rank
	from 
(select product_id,
		sum(quantity) as product_bought,
		sum(amount) as total_revenue 
        from orders	group by product_id) t
        join products p 
        on t.product_id = p.product_id) 
        select category,
			 max(case when bought_rank = 1 then product_name end) as most_bought_product,
             max(case when revenue_rank = 1 then product_name end) as  highest_revenue_product
             from cte group by category;
        
-- 40. Find the median salary for each department;
with cte as
(select *,
	row_number() over(partition by dept order by salary) as rw,
    count(*) over(partition by dept) as total_count
From employees)
		select dept,  avg(salary) as median_salary from cte
        where rw in (floor((total_count + 1) / 2.0),  ceil((total_count + 1) / 2.0))
        group by dept;
    
-- 41. Compute the day when cumulative revenue first exceeded 50% of total revenue (median sales day).
with cte as 
(select *,
	sum(revenue) over(order by order_date) as cum_sum,
    sum(revenue) over() as total_revenue
    from 
(select order_date, sum(amount) as revenue 
		from orders
        group by order_date) t) 
        select min(order_date) as date_ from cte
        where cum_sum > total_revenue / 2;

-- 42. Find percentiles (25th, 50th, 75th) of employee salaries.
with cte as (
select salary,
		row_number() over(order by salary) as rn,
        count(*) over() as total_rows
        from employees)
	select * from cte
    where rn in (floor(total_rows * 0.25),
                    floor(total_rows * .5),
                    floor(total_rows * .75));

-- 43. Retrieve customers with increasing order amounts over their last 3 orders.
with cte as (
select * ,
		lag(amount) over(partition by customer_id order by rw desc) as prev_1,
        lag(amount,2) over(partition by customer_id order by rw desc) as prev_2
from 
(select *,
	row_number() over(partition by customer_id order by order_date desc) as rw
 from orders) t
  where rw < 4)
  select * from cte
		where customer_id is not null and prev_2 is not null
        and amount > prev_1 and prev_1 > prev_2;

-- 44. Calculate 7 day moving average for the revnue;
with cte as 
(select order_date, 
		sum(amount) as day_revenue
        from orders group by order_date)
        select order_date, day_revenue, 
				round(avg(day_revenue) over(order by order_date rows between 6 preceding and current row),2) as moving_average_7days
                from cte;


-- 45. Find the percentage of total sales contributed by top 10% of customers.
with cte as (
select *,
	ntile(10) over(order by total desc) as customer_bucket from
(select customer_id, sum(amount) as total
		from orders group by customer_id) t) 
	select  100.0 * sum(case when customer_bucket = 1  then total else 0 end)  / sum(total) 
        as top_10_percent
        from cte;

-- 46. Calculate weekly active users.

-- 47. Find employees with salary higher than department average.
-- 1
select * from employees e
		where salary > (select avg(salary) from employees 
									where dept = e.dept);

-- 2
select * from 
(select *,
		avg(salary) over(partition by dept) as dept_avg 
        from employees) t
        where salary > dept_avg
        order by emp_id;

-- 48. Calculate average time differnce user signup and their first purchase.
select avg(datediff(order_date, signup_date)) from customers c
		join orders o
        on c.customer_id = o.customer_id
			where o.order_date = (select min(order_date) from orders
														where customer_id = o.customer_id);
with cte as 
(select customer_id, min(order_date)  as first_order 
		from orders
        group by customer_id) 
	select avg(datediff(first_order, signup_date)) as avg_gap from 
	customers c  join cte 
	on cte.customer_id = c.customer_id;

-- 49. Retrieve the longest gap between orders for each customer.
select customer_id, max(datediff(order_date, last_date)) as longest_gap
	from 
(select customer_id,
		order_date, 
		lag(order_date) over(partition by customer_id order by order_date) as last_date
        from orders) t
	where last_date is not null
	group by customer_id;
            
-- 50. Identify customers with revenue below the 10th percentile
with cte as 
(select * ,
	ntile(10) over(order by cust_revenue) as rnk
from
(select customer_id, sum(amount) as cust_revenue 
		from orders group by customer_id) t)
        select customer_id from cte where rnk = 1;