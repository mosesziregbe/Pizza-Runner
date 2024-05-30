----------------------------------
-- Case Study #2 - Pizza Runner
----------------------------------

-- Author: Moses Tega Ziregbe 
-- Tool used: MySQL Server
--------------------------


CREATE DATABASE pizza_runner;
USE pizza_runner;

-- create runners table

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);


INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


-- create customer_orders table

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  
  
  -- create table runner_orders

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  


-- create table pizza_names

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- create table pizza_recipes

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);


INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


-- create table pizza_toppings

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);


INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
  SELECT * FROM runners;
  SELECT * FROM customer_orders;
  SELECT * FROM runner_orders;
  
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
  
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT 
    order_id, 
    customer_id, 
    pizza_id,
    CASE WHEN exclusions IS NULL OR exclusions LIKE "null" THEN NULL
    WHEN TRIM(exclusions) = '' THEN NULL
    ELSE exclusions
    END AS exclusions,
    CASE WHEN extras IS NULL OR extras LIKE "null" THEN NULL
    WHEN TRIM(extras) = '' THEN NULL
    ELSE extras
    END AS extras,
    order_time
FROM
    customer_orders;
    
-- checking customer_orders_temp table
    
SELECT * FROM customer_orders_temp;

DESC customer_orders_temp;

-- creating temporary table for runner_orders

CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT 
    order_id, 
    runner_id, 
    CASE WHEN pickup_time IS NULL OR pickup_time LIKE "null" THEN NULL
    ELSE pickup_time
    END AS pickup_time,
    CASE WHEN distance IS NULL OR distance LIKE "null" THEN NULL
    WHEN distance LIKE '%km' THEN TRIM(REPLACE(distance, 'km', ''))
    ELSE distance
    END AS distance,
	CASE WHEN duration IS NULL OR duration LIKE "null" THEN NULL
    WHEN duration LIKE '%mins' THEN TRIM(REPLACE(duration, 'mins', ''))
    WHEN duration LIKE '%minute' THEN TRIM(REPLACE(duration, 'minute', ''))
    WHEN duration LIKE '%minutes' THEN TRIM(REPLACE(duration, 'minutes', ''))
    ELSE duration
    END AS duration,
    CASE WHEN cancellation IS NULL OR cancellation LIKE "null" OR TRIM(cancellation) = '' THEN NULL
    ELSE cancellation
    END AS cancellation
FROM
    runner_orders;


-- change table to the appropriate datatype
-- first, handle the pickup column to the appropriate datetime format

UPDATE runner_orders_temp
SET pickup_time = STR_TO_DATE(pickup_time, '%Y-%m-%d %H:%i:%s')
WHERE pickup_time IS NOT NULL;

DESC runner_orders_temp;

ALTER TABLE runner_orders_temp
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance DECIMAL(5, 1),
MODIFY COLUMN duration INT;

    
    
DROP TEMPORARY TABLE IF EXISTS customer_orders_temp;
DROP TEMPORARY TABLE IF EXISTS runner_orders_temp;


    
SELECT * FROM runner_orders_temp;

SELECT * FROM runners;
SELECT * FROM customer_orders_temp;
SELECT * FROM runner_orders_temp;
  
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;

