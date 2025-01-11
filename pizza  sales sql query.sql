--Retrieve the total number of orders placed.

select count(order_id) 
as total_order 
from orders;

--Calculate the total revenue generated from pizza sales.

select sum(pizzas.price*order_details.quantity) 
as total_revenue
from pizzas
join order_details
on order_details.pizza_id=pizzas.pizza_id ;

--Identify the highest-priced pizza.

select pizza_types.name,pizzas.price 
from pizza_types
join pizzas 
on pizzas.pizza_type_id=pizza_types.pizza_type_id
order by pizzas.price desc 
limit 1;

--Identify the most common pizza size ordered.

select pizzas.sizes,count(order_details_id) 
as order_count 
from pizzas 
join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.sizes 
order by count(order_details_id) desc
limit 1;

--List the top 5 most ordered pizza types along with their quantities.
with cte as
(select pizza_types.name,sum(order_details.quantity) as total_quantity,
row_number() over (order by sum(order_details.quantity) desc) as rn from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
)
select name,total_quantity from cte
where rn<=5;

--Join the necessary tables to find the total quantity of each pizza category ordered.


select pizza_types.category,sum(order_details.quantity) as total_quantity_ordered
from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by total_quantity_ordered desc;

--Determine the distribution of orders by hour of the day.

select extract(hour from orders.time) as hours,count(order_details.order_id) as total_order 
from order_details
join orders on order_details.order_id=orders.order_id
group by extract(hour from orders.time)
order by extract(hour from orders.time);

--Join relevant tables to find the category-wise distribution of pizzas.


select category,count(name) 
from pizza_types
group by category;

--Group the orders by date and calculate the average number of pizzas ordered per day


select round(avg(quantitys),0) 
from 
(select orders.date,sum(order_details.quantity) as quantitys 
from orders
join order_details on order_details.order_id=orders.order_id
group by orders.date 
order by orders.date) as order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,sum(order_details.quantity*pizzas.price) as total_revenue 
from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by total_revenue desc 
limit 3;

--Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,round((sum(order_details.quantity*pizzas.price)/ (select sum(order_details.quantity*pizzas.price) as total_sales from order_details
join pizzas on order_details.pizza_id=pizzas.pizza_id) *100),2) as revenue from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category;

--Analyze the cumulative revenue generated over time.


select date,sum(revenue) over(order by date) as cum_revenue from
(select orders.date,sum(order_details.quantity*pizzas.price) as revenue from order_details
join pizzas on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.date) as sales;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.


with cte as (
select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as total_revenue,
row_number() over(partition by pizza_types.category order by sum(order_details.quantity*pizzas.price)desc) as rn from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) 
select category,name,total_revenue from cte where rn<=3;






















