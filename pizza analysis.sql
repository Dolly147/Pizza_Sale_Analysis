-- retrieve the total number of orders places.
select count(order_id) as total_orders from orders;


 -- calculate total revenue generated rom pizza sales
select 
ROUND(sum(orders_details.quantity * pizzas.price), 2) as total_sales
from orders_details 
join pizzas
on pizzas.pizza_id = orders_details.pizza_id;


-- Identity the highest priced pizza.
select max(t.price)
FROM
(SELECT pizza_types.name, pizzas.price 
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id) t
order by pizzas.price desc limit 10;


-- Identity the most common pizza size order 
SELECT pizzas.size, Count(pizzas.size) as sizecount
FROM orders_details 
JOIN pizzas 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size 
ORDER BY sizecount desc limit 1;


-- List the top 5 most ordered pizza types along with their quantites;
SELECT pizza_types.name, pizza_types.pizza_type_id, SUM(orders_details.quantity) as tquantity
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name, pizza_types.pizza_type_id
ORDER BY tquantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each category ordered
SELECT pizza_types.category, SUM(orders_details.quantity) as pizzza_quantities
from pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id= pizzas.pizza_type_id
Join orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
order by pizzza_quantities desc;

-- Determine the distribution of orders by hour of the day 
select hour(order_time) as hour, count(order_id) as orderscount
from orders
group by hour(order_time)
order by  hour;

-- join the relevant tables to find the category wise distribution of pizzas
select category, count(name) 
from pizza_types
group by category ;

-- Group the orders by date and calculate the avg no of pizzas ordered per day
select ROUND(avg(t.quan), 2) as avg_pizzas_per_day from
(select orders.order_date, sum(orders_details.quantity) as quan
from orders
JOIN orders_details 
ON orders.order_id = orders_details.order_id
GROUP by orders.order_date) t;


-- Determine the top 3 most ordered pizza types based on revenue
Select  pizza_types.name, SUM(orders_details.quantity * pizzas.price) as revenue
FROM  pizza_types
Join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
on orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
order by revenue desc limit 3;


-- Calculate the percentage contribution of each category type to total revenue;

SELECT t.category,  CONCAT(ROUND((t.revenue / total_revenue.total)* 100, 2), '%') AS percentage
FROM 
(SELECT pizza_types.category, sum(orders_details.quantity * pizzas.price) as revenue
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
order by revenue desc) t, 
 ( SELECT SUM(orders_details.quantity * pizzas.price) AS total
     FROM pizza_types
     JOIN pizzas ON 
     pizza_types.pizza_type_id = pizzas.pizza_type_id
     JOIN orders_details
     ON orders_details.pizza_id = pizzas.pizza_id
    ) total_revenue
ORDER BY t.revenue DESC;


-- analyze the cummulative revenue generated over time
SELECT order_date, ROUND((sum(revenue) over(order by order_date)), 3) as cum_revenu
FROM (Select orders.order_date, SUM(orders_details.quantity * pizzas.price) as revenue
FROM orders_details
JOIN pizzas 
ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) as sales ;


-- Determine the most order pizza types based on the revenue for each pizza category 

SELECT name, revenue
from
(SELECT category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
 (select pizza_types.category, pizza_types.name,
SUM((orders_details.quantity) * pizzas.price) as revenue 
from pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id= pizzas.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category, pizza_types.name) as t
) as b
WHERE rn<= 3;

