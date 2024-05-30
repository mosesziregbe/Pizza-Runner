----------------------------------
-- CASE STUDY #2: DANNY'S DINER --
----------------------------------

-- Author: Moses Tega Ziregbe 
-- Tool used: MySQL Server
--------------------------

-- A. Pizza Metrics

-- How many pizzas were ordered?

SELECT COUNT(order_id) AS pizzas_ordered_count 
FROM customer_orders_temp;

-- How many unique customer orders were made?

SELECT COUNT(DISTINCT customer_id) AS unique_customers_count 
FROM customer_orders_temp;


-- How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS successful_orders 
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;


-- How many of each type of pizza was delivered?

SELECT p.pizza_name, COUNT(c.pizza_id) AS delivered_pizza_count 
FROM pizza_names AS p
JOIN customer_orders_temp AS c
ON p.pizza_id = c.pizza_id
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY p.pizza_name;



-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_name) AS orders_count
FROM customer_orders_temp AS c
JOIN pizza_names AS p
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;


-- What was the maximum number of pizzas delivered in a single order?

-- order_id has to be the exact same order_id with another 
-- order to consider it as a single order from the same customer

SELECT c.order_id, COUNT(pizza_id) AS pizza_per_order
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
ORDER BY pizza_per_order DESC
LIMIT 1;

WITH pizza_count_cte
AS
(
SELECT c.order_id, COUNT(c.pizza_id) AS pizza_per_order
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
)
SELECT order_id, MAX(pizza_per_order)
FROM pizza_count_cte;


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
       COUNT(c.order_id) AS total_delivered_orders,
       SUM(CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 ELSE 0 END) AS pizzas_with_change, 
       SUM(CASE WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1 ELSE 0 END) AS pizza_no_changes
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY c.customer_id;



-- How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS pizza_with_exclusions_and_extras
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
AND c.exclusions IS NOT NULL AND c.extras IS NOT NULL;


-- What was the total volume of pizzas ordered for each hour of the day?

SELECT 
    HOUR(order_time) AS hourly_data,
    COUNT(order_id) AS total_pizza_ordered
FROM
    customer_orders_temp
GROUP BY hourly_data
ORDER BY hourly_data;



-- What was the volume of orders for each day of the week?

SELECT 
    DAYNAME(order_time) AS daily_data,
    COUNT(order_id) AS total_pizza_ordered
FROM
    customer_orders_temp
GROUP BY daily_data
ORDER BY total_pizza_ordered DESC;

