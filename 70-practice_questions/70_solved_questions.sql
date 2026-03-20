use practice2;

-- 1. How to retrieve the second-highest salary of an employee?
select max(salary) from employees
	where salary < (select max(salary) from employees);
    
select * From employees
		order by salary desc limit 1 offset 1;

-- 2. How to get the nth highest salary (5th highest salary) ?
select * from 
(select *, 
		dense_rank() over(order by salary desc) as rnk 
        from employees) t where rnk = 5;

-- 3. How do you fetch all employees whose salary is greater than the average salary?
select * From employees
		where salary > (select avg(salary) from employees);

-- 4. Write a query to display the current date and time.
select current_timestamp();

-- 5. How to find duplicate records in a table?
select emp_id, count(*) as duplicated_rows from employees
		group by emp_id
        having duplicated_rows > 1;

-- 6. How can you delete duplicate rows?
begin;
delete from employees
where emp_id in(
select emp_id
from (select emp_id,
		row_number() over(partition by first_name, last_name, email order by emp_id) as rn
        from employees) t
				where rn > 1);

rollback;

-- 7. How to get the common records from two tables?
select e1.* from employees e1
join employees e2  # use other table if available
on e1.emp_id = e2.emp_id;

select * From employees
where emp_id in (select emp_id From employees);

-- 8. How to retrieve the last 10 records from a table?
select * from employees
order by emp_id desc limit 10;

-- 9. How do you fetch the top 5 employees with the highest salaries?
select * from employees
order by salary desc limit 5;

-- 10. How to calculate the total salary of all employees?
select sum(salary) from employees;

-- 11. How to write a query to find all employees who joined in the year 2020?
select * from employees
	where join_date between '2020-01-01' and '2020-12-31';

-- 12. Write a query to find employees whose name starts with 'A'.
select * from employees
		where first_name like 'A%';

-- 13. How can you find the employees who do not have a manager?
select * from employees
	where manager_id is null;

-- 14. How to find the department with the highest number of employees?
select dept_id, count(*) as emp_count from employees
		group by dept_id
        order by count(*) desc limit 1;

-- 15. How to get the count of employees in each department?
select dept_id, count(*) as emp_counts from employees
		group by dept_id;

-- 16. Write a query to fetch employees having the highest salary in each department.
select dept_id, max(salary)  as max_salary from employees
		group by dept_id;

-- 17. How to write a query to update the salary of all employees by 10%?
begin;

select salary , salary * 1.10 as new_salary  from employees;

update employees
set salary = salary * 1.10;

rollback;

-- 18. How can you find employees whose salary is between 50,000 and 1,00,000?
select * From employees
	where salary between 50000 and 100000;

-- 19. How to find the youngest employee in the organization?
select min(timestampdiff(year, birth_date, curdate())) as age from employees;

-- 20. How to fetch the first and last record from a table?
(select * From employees
	order by emp_id limit 1)
union
(select * from employees
		order by emp_id desc limit 1);

-- 21. Write a query to find all employees who report to a specific manager  (emp_id is 1009).
select * From employees where 
manager_id = 1009;

-- 22. How can you find the total number of departments in the company?
select count(distinct dept_id) as total_dept from employees;

-- 23. How to find the department with the lowest average salary?
select dept_id, avg(salary) as avg_salary from employees
			group by dept_id
            order by avg(salary) asc limit 1;

-- 24. How to delete all employees from a department in one query? (dept_id = 106)
begin;
delete from employees
	where dept_id = 106;
    
select distinct dept_id From employees;
rollback;

-- 25. How to display all employees who have been in the company for more than 5 years?
select * from employees
	where join_date <= date_sub(curdate(), interval 5 year);

-- 26. Find the second-largest salary from the employees table;
select max(salary) from employees
		where salary< (select max(salary) from employees);

-- 27. How to write a query to remove all records from a table but keep the table structure?
-- truncate table employees;

-- 28. Write a query to show full name and department name for employees who joined after 2020;
select concat(first_name, " ", last_name) as full_name, dept_name from employees e
	join departments d 
    on e.dept_id = d.dept_id
    where join_date > "2021-01-01";

-- 29. How to get the current month’s name?
select monthname(curdate());

-- 30. How to convert a string to lowercase?
select lower("This is MulTi case STRINg");

-- 31. How to find all employees who do not have any subordinates?
select * From employees
	where emp_id not in (select distinct manager_id from employees where manager_id is not null);

-- 32. Write a query to calculate the number of employees in each city
select d.city,  count(*) as emp_counts From employees e
		join departments d
        on e.dept_id = d.dept_id
        group by d.city;


-- 33. How to write a query to check if a table is empty?
select 
		case when exists (select 1 from employees) then 'Not Empty'
        else 'Empty' end as table_state;

-- 34. How to find the second highest salary for each department?
select * from 
(select *, 
	dense_rank() over(partition by dept_id order by salary desc) as salary_rank
    from employees) t
    where salary_rank = 2;

-- 35. Write a query to fetch employees whose salary is a multiple of 10,000.
select * from employees
	where salary % 10000 = 0;

-- 36. How to fetch records where a column has null values?
select * from employees
	where bonus is null;

-- 37. How to write a query to find the total number of employees in each job title?
select job_title, count(*) as emp_count from employees
		group by job_title
        order by count(*) desc;

-- 38. Write a query to fetch all employees whose first_name end with ‘n’.
select * From employees
		where first_name like "%n";

-- 39. How to find all employees who work in either of the department (101 or 102)?
select * from employees
		where dept_id in (101, 102);

-- 40. Write a query to fetch the details of employees with the same salary.
select * from employees
	where salary in 
(select salary from employees
		group by salary
        having count(*) > 1);

-- 41. Write a query to update employee salaries based on their department,
-- 		increase the salary by 10% for dept_id = 101, by 5% for dept_id = 105, and by 3% for all other departments
begin;
update employees
set salary = (case when dept_id = 101 then salary * 1.10
							when dept_id = 105 then salary * 1.05
                            else salary * 1.03 end);
rollback;

-- 42. Write a query to list all employees without a department
select * from employees
		where dept_id is null;

-- 43. Write a query to find the maximum salary and minimum salary in each department.
select dept_id, max(salary) as max_salary, min(salary) as min_salary from employees
		group by dept_id
        order by dept_id asc;

-- 44. List all employees hired in the last 2 year?
select * from employees
	where join_date > subdate(curdate(), interval 2 year);
    
-- 45. Write a query to display department-wise total and average salary.
select dept_id, sum(salary) as total_salary, avg(salary) as avg_salary from employees
		group by dept_id
        order by dept_id asc;

-- 46. How to find employees who joined the company in the same month and year as their manager?
select e.* from employees e
join employees m
on e.manager_id = m.emp_id
	where month(e.join_date) = month(m.join_date)
				and year(e.join_date) = year(m.join_date);

-- 47. Write a query to count the number of employees whose first names start and end with the same letter.
select count(*) as total_employes from employees
		where left(first_name, 1) = right(first_name, 1);

-- 48. How to retrieve employee names and salaries in a single string?
select concat(first_name, " ", last_name, "  ->  ", salary )	as name_and_salary from employees;

-- 49. How to find employees whose salary is higher than their manager's salary?
select e.* From employees e
join employees m 
on e.manager_id = m.emp_id
where e.salary > m.salary;

-- 50. Write a query to get employees who belong to departments with less than 30 employees.
select * from employees
	where dept_id in (select distinct dept_id from employees
		group by dept_id
        having count(*) < 30);

-- 51. How to write a query to find employees with the same first name?
select * from employees
where first_name in (select first_name from employees
		group by first_name
        having count(*) > 1);

-- 52. How to write a query to delete employees who have been in the company for more than 8 years?
begin;
select * From employees
		where timestampdiff(year, join_date, curdate()) > 8;

-- 53. Write a query to list all employees working under the same manager .
select * from employees where manager_id = 1003;

-- 54. How to find the top 3 highest-paid employees in each department?
select * from 
(select *, 
		dense_rank() over(partition by dept_id order by salary desc) as rnk
        from employees) t where rnk <= 3;

-- 55. Write a query to list all employees with more than 5 years of experience in each department.
select * From employees where timestampdiff(year, join_date, curdate()) > 5;

-- 56. List all employees in departments that have not hired anyone in the past 2 years?
select * from employees
where dept_id in 
(select dept_id from employees 
		group by dept_id 
        having max(join_date) < curdate() - interval 2 year);
        
-- 57. Write a query to find all employees who earn more than the average salary of their department.
-- 1
select * from 
(select *,
	avg(salary) over(partition by dept_id) as dep_avg_salary
    from employees) t
    where salary > dep_avg_salary;
    
-- 2)
select * From employees e
	where salary > (select avg(salary) from employees where dept_id = e.dept_id);
    
-- 58. How to list all managers who have more than 5 subordinates?
select * from employees
where emp_id in
(select manager_id from employees
		group by manager_id
        having count(*) > 5);

-- 59. Write a query to display employee names and hire dates in the format "first name - MM/DD/YYYY".
select concat(first_name, " - ",  date_format(join_date, "%m/%d/%Y")) as name_hire_date from employees;

-- 60. How to find employees whose salary is in the top 10%?
select * from
(select *,
		ntile(10) over(order by salary desc)  as salary_bucket
        from employees) t
        where salary_bucket = 1;

-- 61. Write a query to display employees grouped by their age brackets.
with cte as 
(select * , timestampdiff(year, birth_date, curdate()) as age from employees)
	select *, 
			case when age <= 30 then 'under_30'
            when age between 31 and 40 then '30_to_40'
            else 'above_40' end as age_bucket
            from cte;

-- 62. How to find the average salary of the top 5 highest-paid employees in each department?
select dept_id, avg(salary) from 
(select *, 
		dense_rank() over(partition by dept_id order by salary desc) as rnk
        from employees) t
        where rnk <=5
        group by dept_id;

-- 63. How to calculate the percentage of employees in each department?
select dept_id, round(100 * count(*)/ (select count(*) from employees), 2) as emp_percentage
	from employees
		group by dept_id;

-- 64. Write a query to find all employees whose email contains the domain '@example.com'.
select * from employees
		where email like "%@example.com";

-- 65. Retrieve the maximum and minimum salary fro each department
select dept_id, max(salary)  as min_salary, min(salary) as max_salary from employees
		group by dept_id;

-- 66. Write a query to display the hire date and day of the week for each employee.
select join_date, dayname(join_date) as week_day from employees;

-- 67. How to find all employees who are older than 45 years?
select *, timestampdiff(year, birth_date, curdate()) from employees
		where  timestampdiff(year, birth_date, curdate()) > 45;
		
-- 68. Write a query to display employees grouped by their salary range.
select *, 
		case when salary < 100000 then "under_100K"
        when salary between 100000 and 150000 then "between_100K_150K"
        when salary between 150001 and 200000 then "between_150K_200K"
        else "above_200K" end as salary_bracket
        from employees;

-- 69. Show to list all employees who do not have a bonus?
select * From employees 
		where bonus is null;

-- 70. Write a query to display the highest, lowest, and average salary for each job role.
select job_title, max(salary) as highest_salary, 
			min(salary) as lowest_salary, 
            avg(salary) as avg_salary from employees
            group by job_title;



