-- Problem 9: Retrieve the top 3 categories with the highest total sales amount
-- Write an SQL query to retrieve the top 3 categories with the highest total sales amount.
-- The result should include the category ID, category name, and the total sales amount.
-- Hint: You may need to use subqueries, joins, and aggregate functions to solve this problem.

SELECT
    c.category_id,
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales_amount
FROM Categories c
JOIN Products p
    ON c.category_id = p.category_id
JOIN Order_Items oi
    ON p.product_id = oi.product_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY total_sales_amount DESC
LIMIT 3;

-- Problem 10: Retrieve the users who have placed orders for all products in the Toys & Games
-- Write an SQL query to retrieve the users who have placed orders for all products in the Toys & Games
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries, joins, and aggregate functions to solve this problem.

-- Key idea: number of Toys & Games products bought by user = total number of Toys & Games products
SELECT
    u.user_id,
    u.username
FROM Users u
JOIN Orders o
    ON u.user_id = o.user_id
JOIN Order_Items oi
    ON o.order_id = oi.order_id
JOIN Products p
    ON oi.product_id = p.product_id
JOIN Categories c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Toys & Games'
GROUP BY
    u.user_id,
    u.username
HAVING COUNT(DISTINCT p.product_id) = (
    SELECT COUNT(*)
    FROM Products p2
    JOIN Categories c2
        ON p2.category_id = c2.category_id
    WHERE c2.category_name = 'Toys & Games'
);

-- Problem 11: Retrieve the products that have the highest price within each category
-- Write an SQL query to retrieve the products that have the highest price within each category.
-- The result should include the product ID, product name, category ID, and price.
-- Hint: You may need to use subqueries, joins, and window functions to solve this problem.

WITH ranked_products AS (
    SELECT
        product_id,
        product_name,
        category_id,
        price,
        RANK() OVER (
            PARTITION BY category_id
            ORDER BY price DESC
        ) AS price_rank
    FROM Products
)
SELECT
    product_id,
    product_name,
    category_id,
    price
FROM ranked_products
WHERE price_rank = 1;

SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.price
FROM Products p
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM Products p2
    WHERE p2.category_id = p.category_id
);

-- Problem 12: Retrieve the users who have placed orders on consecutive days for at least 3 days
-- Write an SQL query to retrieve the users who have placed orders on consecutive days for at least 3 days.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries, joins, and window functions to solve this problem.

WITH distinct_order_dates AS (
    SELECT DISTINCT
        user_id,
        order_date
    FROM Orders
),
numbered_dates AS (
    SELECT
        user_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY order_date
        ) AS rn
    FROM distinct_order_dates
),
grouped_dates AS (
    SELECT
        user_id,
        order_date,
        julianday(order_date) - rn AS streak_group
    FROM numbered_dates
),
streaks AS (
    SELECT
        user_id,
        streak_group,
        COUNT(*) AS streak_length
    FROM grouped_dates
    GROUP BY
        user_id,
        streak_group
)
SELECT DISTINCT
    u.user_id,
    u.username
FROM streaks s
JOIN Users u
    ON s.user_id = u.user_id
WHERE s.streak_length >= 3;