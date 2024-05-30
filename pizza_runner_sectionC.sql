-- C. Ingredient Optimisation

-- What are the standard ingredients for each pizza?

-- normalize the pizza_recipe table
-- join the 3 tables to get the pizza names and topping names
-- GROUP_CONCAT the topping names to get it into a single row

DROP TABLE IF EXISTS pizza_recipes1;
CREATE TABLE pizza_recipes1 (
    pizza_id INT,
    topping_id INT
);


INSERT INTO pizza_recipes1 (pizza_id, topping_id)
VALUES (1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 8),
(1, 10),
(2, 4),
(2, 6),
(2, 7),
(2, 9),
(2, 11),
(2, 12);

SELECT pn.pizza_name, GROUP_CONCAT(pt.topping_name SEPARATOR ', ') AS standard_ingredients FROM 
pizza_recipes1 pr
JOIN pizza_names pn
ON pr.pizza_id = pn.pizza_id
JOIN pizza_toppings pt
ON pt.topping_id = pr.topping_id
GROUP BY pn.pizza_name;



-- What was the most commonly added extra?

DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers (
  num INT PRIMARY KEY
);

INSERT INTO numbers VALUES
    ( 1 ), ( 2 ), ( 3 ), ( 4 ), ( 5 ), ( 6 ), ( 7 ), ( 8 ), ( 9 ), ( 10 ), 
    ( 11 ), ( 12 ), ( 13 ), ( 14 ), ( 15 );


WITH tag_cte AS
(
SELECT 
  SUBSTRING_INDEX(SUBSTRING_INDEX(all_tags, ',', num), ',', -1) AS one_tag,
  COUNT(*) AS count_of_extras
FROM (
  SELECT
    GROUP_CONCAT(extras separator ',') AS all_tags,
    LENGTH(GROUP_CONCAT(extras SEPARATOR ',')) - LENGTH(REPLACE(GROUP_CONCAT(extras SEPARATOR ','), ',', '')) + 1 AS count_tags
  FROM customer_orders_temp
) t
JOIN numbers n
ON n.num <= t.count_tags
GROUP BY one_tag
ORDER BY count_of_extras DESC
)
SELECT one_tag AS extras_id, pt.topping_name AS extra_topping, count_of_extras
FROM tag_cte
JOIN pizza_toppings pt
ON pt.topping_id = tag_cte.one_tag;


-- What was the most common exclusion?

WITH tag_cte AS
(
SELECT 
  SUBSTRING_INDEX(SUBSTRING_INDEX(all_tags, ',', num), ',', -1) AS one_tag,
  COUNT(*) AS count_of_exclusions
FROM (
  SELECT
    GROUP_CONCAT(exclusions separator ',') AS all_tags,
    LENGTH(GROUP_CONCAT(exclusions SEPARATOR ',')) - LENGTH(REPLACE(GROUP_CONCAT(exclusions SEPARATOR ','), ',', '')) + 1 AS count_tags
  FROM customer_orders_temp
) t
JOIN numbers n
ON n.num <= t.count_tags
GROUP BY one_tag
)
SELECT one_tag AS exclusions_id, pt.topping_name AS exclsuion_topping, count_of_exclusions
FROM tag_cte
JOIN pizza_toppings pt
ON pt.topping_id = tag_cte.one_tag
ORDER BY count_of_exclusions DESC;

-- Generate an order item for each record in the customers_orders 
-- table in the format of one of the following:

-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Veg Lovers


WITH RECURSIVE SplitToppings AS (
    SELECT 
        c.order_id,
        c.customer_id,
        c.pizza_id,
        c.exclusions,
        c.extras,
        1 AS topping_index,
        SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', 1), ',', -1) AS exclusion_id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', 1), ',', -1) AS extra_id
    FROM 
        customer_orders_temp c
    UNION ALL
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        exclusions,
        extras,
        topping_index + 1,
        SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', topping_index + 1), ',', -1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', topping_index + 1), ',', -1)
    FROM 
        SplitToppings
    WHERE 
        topping_index < LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) + 1
        OR topping_index < LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1
)
SELECT 
    st.order_id,
    st.customer_id,
    st.pizza_id, st.exclusions, st.extras,
    CONCAT(
        pn.pizza_name,
        CASE 
            WHEN st.exclusions IS NOT NULL THEN CONCAT(' - Exclude ', GROUP_CONCAT(DISTINCT pt_exclusions.topping_name))
            ELSE ''
        END,
        CASE 
            WHEN st.extras IS NOT NULL THEN CONCAT(' - Extra ', GROUP_CONCAT(DISTINCT pt_extras.topping_name))
            ELSE ''
        END
    ) AS order_item
FROM 
    SplitToppings st
JOIN 
    pizza_names pn ON st.pizza_id = pn.pizza_id
LEFT JOIN 
    pizza_toppings pt_exclusions ON st.exclusion_id = pt_exclusions.topping_id
LEFT JOIN 
    pizza_toppings pt_extras ON st.extra_id = pt_extras.topping_id
GROUP BY
    st.order_id, st.customer_id, st.pizza_id, pn.pizza_name, st.exclusions, st.extras;



-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT
    pt.topping_name,
    COUNT(co.order_id) AS total_quantity
FROM
    pizza_toppings AS pt
LEFT JOIN
    customer_orders_temp AS co ON FIND_IN_SET(pt.topping_id, REPLACE(co.extras, ' ', '')) > 0
LEFT JOIN
    runner_orders_temp AS ro ON co.order_id = ro.order_id AND ro.cancellation IS NULL
GROUP BY
    pt.topping_name
ORDER BY
    total_quantity DESC;



SELECT
    pt.topping_name,
    COUNT(*) AS ingredient_count
FROM
    customer_orders_temp AS co
JOIN
    pizza_toppings AS pt ON FIND_IN_SET(pt.topping_id, co.exclusions) OR FIND_IN_SET(pt.topping_id, co.extras)
GROUP BY
    pt.topping_name
ORDER BY
    ingredient_count DESC;
    
    