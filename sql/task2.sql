-- Problem 5: Retrieve the products with the highest average rating
-- Write an SQL query to retrieve the products with the highest average rating.
-- The result should include the product ID, product name, and the average rating.
-- Hint: You may need to use subqueries or common table expressions (CTEs) to solve this problem.

-- WITH product_ratings as (
--     SELECT 
--         Products.product_id,
--         Products.product_name,
--         AVG(Reviews.rating) AS average_rating
--     FROM Products
--     LEFT JOIN Reviews
--         ON Products.product_id = Reviews.product_id
--     GROUP BY 
--         Products.product_id,
--         Products.product_name
-- )
-- SELECT
--     product_id,
--     product_name,
--     average_rating
-- FROM product_ratings
-- ORDER BY average_rating desc
-- LIMIT 1;                        -- not correct if multiple products have highest rating

WITH product_ratings AS (
    SELECT
        p.product_id,
        p.product_name,
        AVG(r.rating) AS average_rating
    FROM Products p
    JOIN Reviews r
        ON p.product_id = r.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    average_rating
FROM product_ratings
WHERE average_rating = (
    SELECT MAX(average_rating)
    FROM product_ratings
);

WITH product_ratings AS (
    SELECT
        p.product_id,
        p.product_name,
        AVG(r.rating) AS average_rating
    FROM Products p
    JOIN Reviews r
        ON p.product_id = r.product_id
    GROUP BY
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        average_rating,
        RANK() OVER (ORDER BY average_rating DESC) AS rating_rank
    FROM product_ratings
)
SELECT
    product_id,
    product_name,
    average_rating
FROM ranked_products
WHERE rating_rank = 1;

-- Problem 6: Retrieve the users who have made at least one order in each category
-- Write an SQL query to retrieve the users who have made at least one order in each category.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries or joins to solve this problem.

-- Key idea: number of distinct categories bought by user = total number of categories
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
GROUP BY
    u.user_id,
    u.username
HAVING COUNT(DISTINCT p.category_id) = (
    SELECT COUNT(*)
    FROM Categories
);

-- Problem 7: Retrieve the products that have not received any reviews
-- Write an SQL query to retrieve the products that have not received any reviews.
-- The result should include the product ID and product name.
-- Hint: You may need to use subqueries or left joins to solve this problem.

SELECT
    p.product_id,
    p.product_name
FROM Products p
LEFT JOIN Reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING COUNT(r.review_id) = 0

SELECT
    p.product_id,
    p.product_name
FROM Products p
LEFT JOIN Reviews r
    ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

SELECT
    p.product_id,
    p.product_name
FROM Products p
WHERE NOT EXISTS (
    SELECT 1
    FROM Reviews r
    WHERE r.product_id = p.product_id
);

-- Problem 8: Retrieve the users who have made consecutive orders on consecutive days
-- Write an SQL query to retrieve the users who have made consecutive orders on consecutive days.
-- The result should include the user ID and username.
-- Hint: You may need to use subqueries or window functions to solve this problem.

-- WITH order_history AS (
--     SELECT
--         o.user_id,
--         o.order_date,
--         LAG(o.order_date) OVER (PARTITION BY o.user_id ORDER BY o.order_date) AS previous_order_date
--     FROM Orders o
-- )
-- SELECT DISTINCT
--     u.user_id,
--     u.username
-- FROM order_history oh
-- JOIN Users u
--     ON oh.user_id = u.user_id
-- WHERE julianday(oh.order_date) - julianday(oh.previous_order_date) = 1;

WITH distinct_order_dates AS (
    SELECT DISTINCT
        user_id,
        order_date
    FROM Orders
),
previous_orders AS (
    SELECT
        user_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY user_id
            ORDER BY order_date
        ) AS previous_order_date
    FROM distinct_order_dates
)
SELECT DISTINCT
    u.user_id,
    u.username
FROM previous_orders po
JOIN Users u
    ON po.user_id = u.user_id
WHERE julianday(po.order_date) - julianday(po.previous_order_date) = 1;