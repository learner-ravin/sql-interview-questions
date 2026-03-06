create database practice_db;

use practice_db;

-- Creating tables 
create table employees(
	emp_id int primary key,
    first_name varchar(60) not null,
    last_name varchar(60) not null,
    dept varchar(40),
    salary int,
    manager_id int,
    join_date date);
    
    
create table customers(
	customer_id int primary key, 
    customer_name varchar(120) not null,
    region varchar(10) not null,
    signup_date date);
    
create table products(
	product_id int primary key,
    product_name varchar(256),
    category varchar(40),
    price decimal(10,2));
    
create table orders(
	order_id int primary key,
    customer_id int,
    product_id int,
    order_date date,
    quantity int,
    amount decimal(10,2),
    constraint fk_customer foreign key (customer_id) references customers(customer_id)
    on delete cascade
    on update cascade,    
    constraint fk_product foreign key(product_id) references products(product_id)
    on delete cascade
    on update cascade);

    