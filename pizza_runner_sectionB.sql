-- B. Runner and Customer Experience

SELECT * FROM runners;
SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
  
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    WEEK(registration_date, 1) AS week_number,
    COUNT(*) AS num_runners_signed_up
FROM 
    runners
WHERE 
    registration_date >= '2021-01-01'
GROUP BY 
    WEEK(registration_date, 1)
ORDER BY 
    WEEK(registration_date, 1);
    

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?


SELECT r.runner_id, ROUND(AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time))) AS average_arrival_time
FROM runner_orders_temp AS r
JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY r.runner_id;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH pizza_cte AS
(
SELECT c.order_id, 
	   COUNT(c.order_id) AS pizza_ordered, 
       TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_mins
FROM runner_orders_temp AS r
JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT pizza_ordered, ROUND(AVG(prep_time_mins)) AS avg_prep_time
FROM pizza_cte
GROUP BY pizza_ordered;


-- What was the average distance travelled for each customer?

SELECT c.customer_id, ROUND(AVG(r.distance), 1) AS distance_travelled_km 
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
GROUP BY c.customer_id;


-- What was the difference between the longest and shortest delivery times for all orders?

WITH pizza_duration_cte
AS
(
SELECT c.order_id, r.duration AS duration
FROM runner_orders_temp AS r
JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
)
SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM pizza_duration_cte;



-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    r.runner_id,
    c.customer_id,
    c.order_id,
    r.distance,
    ROUND((r.distance) / (r.duration / 60), 2) AS average_speed
FROM
    runner_orders_temp AS r
        JOIN
    customer_orders_temp AS c ON r.order_id = c.order_id
    WHERE r.cancellation IS NULL
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, average_speed
ORDER BY r.runner_id, c.order_id;



-- What is the successful delivery percentage for each runner?

SELECT 
  runner_id, 
  ROUND(100 * SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) / COUNT(*)) AS successful_delivery_percentage
FROM runner_orders_temp
GROUP BY runner_id;


