-- Problem 1: Retrieve all products in the Sports category
-- Write an SQL query to retrieve all products in a specific category.

-- SELECT
--     Products.product_id,
--     Products.product_name,
--     Products.description,
--     Products.price,
--     Categories.category_name
-- FROM Categories
-- JOIN Products
--     ON Products.category_id = Categories.category_id
-- WHERE Categories.category_name = 'Sports';

SELECT
    p.product_id,
    p.product_name,
    p.description,
    p.price,
    c.category_name
FROM Products p
JOIN Categories c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Sports';

-- Problem 2: Retrieve the total number of orders for each user
-- Write an SQL query to retrieve the total number of orders for each user.
-- The result should include the user ID, username, and the total number of orders.

-- SELECT
--     Users.user_id,
--     Users.username,
--     COUNT(Orders.order_id) AS total_orders
-- FROM Users
-- LEFT JOIN Orders
--     ON Users.user_id = Orders.user_id
-- GROUP BY
--     Users.user_id,
--     Users.username;

SELECT
    u.user_id,
    u.username,
    COUNT(o.order_id) AS total_orders   -- count(*) would count users with zero orders as 1 because the LEFT JOIN still keeps one user row with NULL order values, so we use COUNT(o.order_id) to count only existing orders 
FROM Users u
LEFT JOIN Orders o                      -- keeps users who have zero orders
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.username;

-- Problem 3: Retrieve the average rating for each product
-- Write an SQL query to retrieve the average rating for each product.
-- The result should include the product ID, product name, and the average rating.

-- SELECT 
--     Products.product_id, 
--     Products.product_name, 
--     AVG(Reviews.rating) as average_rating
-- FROM Products
-- LEFT JOIN Reviews
--     ON Reviews.product_id = Products.product_id
-- GROUP BY 
--     Products.product_id,
--     Products.product_name;

SELECT
    p.product_id,
    p.product_name,
    AVG(r.rating) AS average_rating
FROM Products p
LEFT JOIN Reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name;

-- Problem 4: Retrieve the top 5 users with the highest total amount spent on orders
-- Write an SQL query to retrieve the top 5 users with the highest total amount spent on orders.
-- The result should include the user ID, username, and the total amount spent.

-- SELECT
--     Users.user_id,
--     Users.username,
--     SUM(Orders.total_amount) as total_amount_spent
-- FROM Users
-- LEFT JOIN Orders
--     ON Users.user_id = Orders.user_id
-- GROUP BY 
--     Users.user_id,
--     Users.username
-- ORDER BY total_amount_spent desc
-- LIMIT 5;

SELECT
    u.user_id,
    u.username,
    SUM(o.total_amount) AS total_amount_spent
FROM Users u
JOIN Orders o
    ON u.user_id = o.user_id
GROUP BY
    u.user_id,
    u.username
ORDER BY total_amount_spent DESC
LIMIT 5;