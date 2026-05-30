USE Data_analytics;


SELECT * FROM customer_sales;



-- check duplicates values

SELECT
    OrderID,
    COUNT(*) AS duplicate_count
FROM customer_sales
GROUP BY OrderID
HAVING COUNT(*) > 1;
-- no duplicate OrderID value 



-- Check missing values

SELECT * FROM customer_sales;


SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN OrderID IS NULL OR TRIM(OrderID) = '' THEN 1 ELSE 0 END) AS missing_orderid,
    SUM(CASE WHEN Date IS NULL OR TRIM(Date) ='' THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN CustomerID IS NULL OR TRIM(CustomerID) ='' THEN 1 ELSE 0 END) AS misssing_customerid,
    SUM(CASE WHEN Quantity IS NULL OR TRIM(Quantity)='' THEN 1 ELSE 0 END) AS missomg_quantity,
    SUM(CASE WHEN UnitPrice IS NULL OR TRIM(UnitPrice)='' THEN 1 ELSE 0 END) AS missing_UnitPrice,
    SUM(CASE WHEN ItemsInCart IS NULL OR TRIM(ItemsInCart)='' THEN 1 ELSE 0 END) AS missing_items,
    SUM(CASE WHEN CouponCode IS NULL OR TRIM(CouponCode)='' THEN 1 ELSE 0 END) AS missing_couponcode,
    SUM(CASE WHEN TotalPrice IS NULL OR TRIM(TotalPrice) ='' THEN  1 ELSE 0 END) AS missing_price
    FROM customer_sales;

-- 309 missing coupon codes

-- Standardize text columns


UPDATE customer_sales
SET
    OrderID = TRIM(OrderID),
    CustomerID = TRIM(CustomerID),
    Product = TRIM(Product),
    ShippingAddress = TRIM(ShippingAddress),
    PaymentMethod = TRIM(PaymentMethod),
    OrderStatus = TRIM(OrderStatus),
    TrackingNumber = TRIM(TrackingNumber),
    CouponCode = TRIM(CouponCode),
    ReferralSource = TRIM(ReferralSource),
    TotalPrice = TRIM(TotalPrice)
    FROM customer_sales;

SELECT TOP 1 *
FROM customer_sales;


-- Replace missing coupon codes



UPDATE customer_sales
SET CouponCode ='No_couponcode'
WHERE CouponCode  IS NULL OR TRIM(CouponCode) ='';


SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN CouponCode IS NULL OR TRIM(CouponCode) ='' THEN  1 ELSE 0 END) AS missing_couponcode
FROM customer_sales;
-- IT CHECKS MISSING VALUES IF 1 MISSING ELSE 0


-- 1. orders above 2000

SELECT  -- change datetype as every columns was text with changing table name and also trasnforming with data
    OrderID,
    Date,
    CustomerID,
    Product,
    CAST(Quantity AS INT) AS Quantity,
    CAST(UnitPrice AS FLOAT) AS UnitPrice,
    ShippingAddress,
    PaymentMethod,
    OrderStatus,
    TrackingNumber,
    CAST(ItemsInCart AS INT) AS ItemsInCart,
    CouponCode,
    ReferralSource,
    CAST(TotalPrice AS FLOAT) AS TotalPrice
INTO customer_sales_clean
FROM customer_sales;



 SELECT * 
FROM customer_sales_clean 
WHERE TotalPrice > 2000;


-- 2. find rows orders above 2000 and Delivered orders only

SELECT * FROM customer_sales_clean
WHERE
TotalPrice > 2000 AND OrderStatus = 'Delivered'
ORDER BY TotalPrice DESC;

-- 3. find customerid where customer Orders paid by Credit Card

SELECT CustomerID from customer_sales_clean
WHERE PaymentMethod = 'Credit Card';  -- 234 rows paid by credit card

-- 4.  Highest sales first - only specific columns

SELECT  TOP 1  CustomerID, Product, Quantity, TotalPrice FROM customer_sales_clean
ORDER BY TotalPrice DESC;

-- 5. lowest sales rows

SELECT TOP 1 * FROM customer_sales_clean ORDER  BY TotalPrice ASC; --TOTALPRICE = 11.39

-- 6. COUNT() Number of unique customers

SELECT COUNT(DISTINCT OrderID) AS order_count FROM customer_sales_clean; -- 1200 rows of order

-- 7. Total Revenue

SELECT SUM(TotalPrice) as total_price FROM customer_sales_clean; -- totalprice = 1264761.96

-- 8. . AVG() Average Order Value

SELECT AVG(TotalPrice) AS AverageOrderValue
FROM customer_sales_clean; -- avg order = 1053.9683

 --- 9. GROUP BY Revenue by Product

 SELECT  Product, SUM(TotalPrice) AS revenue
 FROM customer_sales_clean
 GROUP BY Product
 ORDER BY revenue DESC;

 -- 10. Number of Orders by Product

 SELECT Product, COUNT(*) AS Total_order
 FROM customer_sales_clean
 GROUP BY Product
 ORDER BY Total_order DESC;

 -- 11. Average Sales per Product

 SELECT Product, AVG(TotalPrice) as avg_sales
 FROM customer_sales_clean
 GROUP BY Product
  ORDER BY avg_sales DESC;

  -- 12. Orders by Payment Method

  SELECT PaymentMethod, COUNT(*) AS order_collected  FROM customer_sales_clean
  GROUP BY PaymentMethod
  ORDER BY order_collected DESC;  -- ONLINE METHOD HAS MOST ORDER COLLECTED = 258

 -- 13. Revenue by Payment Method

 
  SELECT PaymentMethod, SUM(TotalPrice) AS revenure  FROM customer_sales_clean
  GROUP BY PaymentMethod
  ORDER BY revenure DESC; 

  -- 14. find Products with more than 170 orders

    SELECT Product, COUNT(*) AS total_order  FROM customer_sales_clean
    GROUP BY Product
    HAVING COUNT(*) > 170
    ORDER BY total_order DESC;


-- 15. Which product generated the highest revenue?

SELECT TOP 1 Product,
       SUM(TotalPrice) AS Revenue
FROM customer_sales_clean
GROUP BY Product
ORDER BY Revenue DESC; -- CHAIR GENERTED HISHESH REVENUE

-- 16. Which referral source generated the most orders?

SELECT ReferralSource, COUNT(*) AS referal_total
FROM customer_sales_clean
GROUP BY ReferralSource
ORDER BY referal_total DESC;  -- Instagram has generated the most

-- 17. Which payment method is most popular?
 
  SELECT PaymentMethod, COUNT(*) AS payment_method FROM customer_sales_clean
  GROUP BY PaymentMethod
  ORDER BY payment_method DESC;  -- online is the most popular payment method

-- 18.  Total revenue by order status

SELECT OrderStatus, SUM(TotalPrice) AS revnue_per_orderstatus 
FROM customer_sales_clean
GROUP BY OrderStatus
ORDER BY revnue_per_orderstatus DESC;

-- 10 check unique products

SELECT DISTINCT Product
FROM customer_sales_clean;


SELECT COUNT(DISTINCT Product) AS TotalProducts
FROM customer_sales_clean;


-- 20.   Validate Quantity  - Check for impossible quantities:

SELECT *
FROM customer_sales_clean
WHERE Quantity <= 0; -- empty means, there is quantity

--- 21. Validate Unit Price

SEL ECT *
FROM customer_sales_clean
WHERE UnitPrice <= 0

-- 22. check date type

SELECT TOP 10 Date
FROM customer_sales_clean;

-- 23. split date into sepeate column Year, month, day

-- Split Date into Year, Month, and Day
-- syntax - SUBSTRING(Date, start, length)



-- Add Date to table permaently

ALTER TABLE customer_sales_clean
ADD Year VARCHAR(4),
    Month VARCHAR(2),
    DAY VARCHAR(2);

-- Then update the values:

UPDATE customer_sales_clean
SET
Year = SUBSTRING(Date,1,4),
Month = SUBSTRING(Date, 6,2),
Day = SUBSTRING(Date, 9, 2);


-- 24 concat qunatity and unit price and add totalprice

SELECT CONCAT(Unitprice, ' * ',Quantity) AS CALCULATION_PRICE, TotalPrice
FROM customer_sales_clean;



-- 25. Subqueries

-- 1. Customers who spent more than average order value

SELECT CustomerID, TotalPrice
FROM customer_sales_clean 
WHERE TotalPrice > ( SELECT AVG(TotalPrice) FROM customer_sales_clean); -- 491 rows

-- 2. Products that generate above-average revenue

SELECT product, SUM(TotalPrice) as revenue FROM customer_sales_clean
GROUP BY product 
HAVING SUM(TotalPrice) > (SELECT AVG(TotalPrice) FROM customer_sales_clean);

-- 3. Customers who made the highest order

SELECT CustomerID, TotalPrice FROM customer_sales_clean
WHERE TotalPrice = (SELECT MAX(TotalPrice) FROM customer_sales_clean);
-- C57276 this customer has maximum order

-- 4. Orders from customers who used Credit Card

SELECT * FROM customer_sales_clean
WHERE CustomerID IN (SELECT CustomerID FROM customer_sales_clean
WHERE PaymentMethod =   'Credit Card'); 

-- 26. Nested Subqueries

-- 1. Top 3 expensive orders 

SELECT * FROM customer_sales_clean 
WHERE TotalPrice IN ( SELECT TOP 3 TotalPrice from customer_sales_clean
ORDER BY TotalPrice DESC);

-- 2. Products sold in “Delivered” orders only
SELECT 

SELECT DISTINCT Product
FROM customer_sales_clean
WHERE OrderID IN (
    SELECT OrderID
    FROM customer_sales_clean
    WHERE OrderStatus = 'Delivered'
);


-- 27. LIKE - Customers whose ID starts with C7

SELECT CustomerID FROM customer_sales_clean
WHERE CustomerID like 'C7%';

-- 28. Orders where Tracking number ends with 24

SELECT TrackingNumber FROM customer_sales_clean
WHERE  TrackingNumber LIKE '%24';

-- 29. Products containing “a”

SELECT DISTINCT Product FROM customer_sales_clean
WHERE  Product LIKE '%a%';

-- 30. NULL / IS NULL / COALESCE - . Find missing coupon codes

SELECT * FROM customer_sales_clean
WHERE CouponCode IS NULL;  -- NO NULL, HAS IT HAS BEEN FILL WITH NO_COUPON EMPTY ROWS

-- 31. Replace NULL coupon codes using COALESCE (display only)

SELECT OrderID, COALESCE(CouponCode, 'NO-COUPON')  AS coalese_fill
FROM customer_sales_clean;

-- 32. Count missing values

SELECT COUNT(*) AS MISSSING_Coupon
FROM customer_sales_clean
WHERE CouponCode IS NULL OR CouponCode='';

-- 33. Show safe payment method (NULL handling example)

SELECT 
    OrderID,
    COALESCE(PaymentMethod, 'UNKNOWN') AS PaymentMethod
FROM customer_sales_clean;
-- but payment method has no missinf values


SELECT TOP 10 *  FROM customer_sales_clean;



