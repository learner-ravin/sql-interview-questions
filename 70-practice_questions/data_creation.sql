create database practice2;

use practice2;

create table departments(
	dept_id int not null,
    dept_name varchar(128) not null,
    city varchar(128) not null);
    
INSERT INTO departments (dept_id, dept_name, city) VALUES
(101, 'Engineering',          'San Francisco'),
(102, 'Product Management',   'Seattle'),
(103, 'Marketing',            'New York'),
(104, 'Sales',                'Chicago'),
(105, 'Finance',              'Boston'),
(106, 'Human Resources',      'Austin'),
(107, 'Customer Success',     'Atlanta'),
(108, 'Data Science',         'San Francisco'),
(109, 'Legal & Compliance',   'Washington'),
(110, 'Operations',           'Denver');

create table employees(
		emp_id int primary key,
        first_name varchar(30) not null,
        last_name varchar(30) not null,
        salary decimal(10,2),
        dept_id int not null,
        manager_id int,
        join_date date,
        birth_date date,
        job_title varchar(128) not null,
        email varchar(128) unique,
        bonus decimal(10, 2));
        
        
create table temp(
		emp_id int primary key,
        first_name varchar(30) not null,
        last_name varchar(30) not null,
        salary decimal(10,2),
        dept_id int not null,
        manager_id int,
        join_date date,
        birth_date date,
        job_title varchar(128) not null,
        email varchar(128) ,
        bonus decimal(10, 2));
        

select * from employees;
truncate table employees;
