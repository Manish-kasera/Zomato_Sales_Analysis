use zomatosales;

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1. what is total amount each customer spent on zomato.

select * from sales; -- userid ,product_id
select * from product; -- product_id,price

SELECT 
    sales.userid, SUM(price) AS total_spend
FROM
    sales
        INNER JOIN
    product ON sales.product_id = product.product_id
GROUP BY sales.userid;

-- 2. How many days has each customer visited zomato?
 
 
SELECT 
    userid, COUNT(DISTINCT (created_date)) AS number_of_visits
FROM
    sales
GROUP BY userid;
 

-- 3. what was the first product purchased by each customer?
SELECT 
   test.userid,
   created_date,
   product_name,
   ranka
FROM   
(SELECT
   sales.userid,
   product_name,
   created_date,
   RANK() OVER(PARTITION BY sales.userid ORDER BY created_date) as ranka
FROM sales
INNER JOIN product
ON sales.product_id = product.product_id
) as test
WHERE ranka = 1;
 
-- 4. what is most purchased item on menu & how many times was it purchased by all customers ?
 
SELECT 
      userid,
      product_id as most_purcahsed_item_on_menu,
	 COUNT(product_id) times_purchased
FROM sales 
WHERE product_id  =
(SELECT 
    product_id
FROM
    sales
GROUP BY product_id
ORDER BY COUNT(product_id) desc
LIMIT 1)
GROUP by userid,product_id;
 
-- 5.which item was most popular for each customer?

SELECT 
   userid,
   product_id as most_purchased_item_customer_wise
FROM   
(SELECT
     userid,
     product_id,
	 COUNT(product_id) purchase_times,
     RANK() OVER(PARTITION BY userid ORDER BY count(product_id) DESC) as ranka
FROM sales 
GROUP BY userid,product_id
ORDER BY userid
) as subquery
WHERE ranka = 1;

select * from sales;
 
-- 6. which item was purchased first by customer after they become a member?
select * from goldusers_signup;
select * from sales;

SELECT 
      *
FROM
(SELECT
   sales.userid, 
   product_id,
   created_date,
   goldusers_signup.gold_signup_date,
  RANK() OVER(PARTITION BY sales.userid ORDER BY created_date ASC) AS ranka
FROM goldusers_signup
INNER JOIN sales
ON goldusers_signup.userid = sales.userid
WHERE sales.created_date >= goldusers_signup.gold_signup_date
ORDER BY sales.created_date ASC
) AS subquery
WHERE ranka = 1;
 
 
-- 7.Which item was purchased just before customer became a member?
 SELECT 
      *
FROM
(SELECT
  sales.userid, 
  product_id ,
  created_date,
  goldusers_signup.gold_signup_date,
  rank() over(PARTITION BY sales.userid ORDER BY created_date DESC) as ranka
FROM goldusers_signup
INNER JOIN sales
ON goldusers_signup.userid = sales.userid
where sales.created_date <= goldusers_signup.gold_signup_date
ORDER BY sales.created_date ASC
) as subquery
WHERE ranka = 1;
 
 
 
-- 8. What is total orders and amount spent for each member before they become a member?
 
 select * from users;
 select * from sales; -- user_id,product_id
 select * from product; -- product_id,price
 select * from goldusers_signup; -- userid,gold_signup_date
 
SELECT 
    s.userid, 
    COUNT(s.product_id) as order_purchased, 
    SUM(price) as total_amount_spend
FROM
    sales AS s
        JOIN
    product AS p ON s.product_id = p.product_id
        JOIN
    goldusers_signup AS g ON s.userid = g.userid
WHERE
    s.created_date < g.gold_signup_date
GROUP BY s.userid
ORDER BY SUM(price) DESC;
 
 
/*9.
If buying each product generate points for eg 5rs=2 zomato point 
and each product has different purchasing points 
for eg for p1 5rs=1 zomato point,
for p2 10rs-5 zomato points and p3 5rs=1 zomato points. 
calculate points collected by each customers
and for which product most points have been given till now. 
*/

select * from sales; -- userid,product_id
select * from product; -- product_id,price

SELECT userid,
   SUM(points) as total_points_earned,
   SUM(points) * 2.5 as total_money_earned
FROM
(SELECT 
    userid,
    p.product_name,
    p.price,
    CASE
      WHEN p.product_name = 'p1' THEN ROUND(p.price/5) 
      WHEN p.product_name = 'p2' THEN ROUND(p.price/2)
      WHEN p.product_name = 'p3' THEN ROUND(p.price/5)
    END as points
FROM sales AS s
JOIN product AS p
on s.product_id = p.product_id) subquery 
GROUP By userid;


SELECT 
    product_name,
    sum(points) as total_points_earned
FROM
(SELECT 
    userid,
    p.product_name,
    p.price,
    CASE
      WHEN p.product_name = 'p1' THEN ROUND(p.price/5) 
      WHEN p.product_name = 'p2' THEN ROUND(p.price/2)
      WHEN p.product_name = 'p3' THEN ROUND(p.price/5)
    END as points
from sales AS s
JOIN product AS p
ON s.product_id = p.product_id) subquery
GROUP BY product_name
ORDER By total_points_earned DESC
LIMIT 1;

/*10. In the first one year after customer joins the gold program (including the join date) 
irrespective of what customer has purchased earn 5 zomato points for every 10rs spent 
who earned more more 1 or 3
 what int earning in first yr? 1zp = 2rs
*/

SELECT subquery.*,
    d.price, 
    d.price * 0.5 as points_earned
FROM
(
SELECT
  s.userid, 
  product_id,
  created_date,
  g.gold_signup_date
FROM goldusers_signup g
INNER JOIN sales as s
ON g.userid = s.userid
WHERE s.created_date >= g.gold_signup_date 
AND s.created_date <= DATE_ADD(g.gold_signup_date, INTERVAL 1 YEAR)
) subquery
INNER JOIN product d
ON subquery.product_id = d.product_id;

-- SELECT DATE_ADD('2017/08/25', INTERVAL 1 Year) AS DateAdd; 
 
-- 11. rnk all transaction of the customers
select *,
   RANK() OVER(partition by  userid ORDER BY created_date DESC) AS ranka
 FROM sales;
 
-- 12. rank all transaction for each member whenever they are 
-- zomato gold member for every non gold member transaction mark as na

SELECT *,
    IF (created_date >= gold_signup_date ,
    RANK() OVER(PARTITION BY s.userid ORDER BY created_date DESC),
    'na') AS ranka
FROM sales s
LEFT JOIN goldusers_signup g
ON s.userid = g.userid;
