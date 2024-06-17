create database pizzahut;
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);
create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
);
select * from orders;
select * from order_details;

-- 1) Retrieve the total number of orders placed.
select count(order_id) total_orders from orders;

-- 2) Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_sales from order_details join pizzas on pizzas.pizza_id = order_details.pizza_id;

-- 3) Identify the highest-priced pizza.
select pizza_types.name, pizzas.price from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id order by pizzas.price desc limit 1;

-- 4) Identify the most common pizza size ordered.
select quantity, count(order_details_id) from order_details group by quantity;
select p.size, count(od.order_details_id) cod from pizzas p join order_details od on p.pizza_id = od.pizza_id group by p.size order by cod desc;

-- 5) List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) quantity from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.name order by quantity desc limit 5;

-- 6) Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category pizza_category , sum(order_details.quantity) quantity from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_category order by quantity desc;

-- 7) Determine the distribution of orders by hour of the day.
select hour(order_time) hour, count(order_id) order_count from orders
group by hour;

-- 8) Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types group by category;

-- 9) Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity)) as avg_pizzas_ordered_perday from
(select orders.order_date, sum(order_details.quantity) quantity from orders 
join order_details on orders.order_id = order_details.order_id group by orders.order_date) as order_quantity;

-- 10) Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue from pizza_types 
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id 
join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.name order by revenue desc limit 3;

-- 11) Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, round((sum(order_details.quantity * pizzas.price)/ (select round(sum(order_details.quantity * pizzas.price),2) as total_sales from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id) )*100,2) revenue from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.category order by revenue desc;

-- 12) Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) cum_revenue from (select orders.order_date, 
sum(order_details.quantity * pizzas.price) revenue
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id group by orders.order_date) sales;
 
-- 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue, rank() over(partition by category order by revenue desc) ranking from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity) * pizzas.price) revenue from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.category, pizza_types.name) a;
 