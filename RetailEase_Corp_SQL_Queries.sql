-- Customer Insights

-- Count the number of customers in each subscription status (Yes/No)

SELECT   Subscription_Status,
	 COUNT(Customer_ID) AS Customer_Count
FROM customer_table
GROUP BY Subscription_Status
ORDER BY Customer_Count DESC;

-- Find the average age of customers grouped by gender

SELECT Gender,
       AVG(Age) AS Average_Age
FROM customer_table
GROUP BY Gender 
ORDER BY Gender;

-- Identify customers who made more than 5 purchases but have a low review rating of less than 3

SELECT customer_table.Review_Rating,
       COUNT(product_table.Frequency_of_Purchases) AS Purchases
FROM customer_table
Right JOIN product_table
ON customer_table.Product_ID = product_table.Product_ID
GROUP BY Review_Rating
HAVING COUNT(product_table.Frequency_of_Purchases) < 3;

-- Determine the frequency of purchases for customers grouped by their preferred payment method

SELECT transaction_table.Preferred_Payment_Method,
       COUNT(Product_Table.Frequency_of_Purchases) AS Frequency_of_Purchase
FROM transaction_table
INNER JOIN product_table
ON transaction_table.Product_ID = product_table.Product_ID
GROUP BY Preferred_Payment_Method
ORDER BY Preferred_Payment_Method;

-- Identify the top 5 customers with the highest total purchase amount

WITH Ranked_Customers AS (
    SELECT customer_table.Customer_ID,
		   Purchase_Amount_USD,
		   RANK() OVER (ORDER BY transaction_table.Purchase_Amount_USD DESC) AS Customer_Rating
    FROM transaction_table
    LEFT JOIN customer_table
    ON transaction_table.Customer_ID = customer_table.Customer_ID
)
SELECT Customer_ID,
       Purchase_Amount_USD,
       Customer_Rating
FROM Ranked_Customers
WHERE Customer_Rating <= 5;



-- Sales Performance

-- Calculate the total number of transactions made using each payment method

SELECT Payment_Method,
       COUNT(Trans_ID) AS Total_Transactions
FROM transaction_table
GROUP BY Payment_Method
ORDER BY Total_Transactions DESC;

-- Determine which location generated the most revenue

SELECT Location,
       SUM(Purchase_Amount_USD) AS Revenue_Generated
FROM transaction_table
GROUP BY Location
ORDER BY Revenue_Generated DESC;

-- Find the total sales and average purchase amount(round to 2 decimal places) for each promo code used

SELECT Promo_Code_Used,
       SUM(Purchase_Amount_USD) AS Total_Sales,
       ROUND(AVG(Purchase_Amount_USD), 2) AS Average_Purchase_Amount
FROM transaction_table
GROUP BY Promo_Code_Used
ORDER BY Total_Sales;

-- Calculate the total sales revenue for each product category

SELECT Category,
       SUM(transaction_table.Purchase_Amount_USD) AS Total_Sales
FROM product_table
RIGHT JOIN transaction_table
ON product_table.Product_ID=transaction_table.Product_ID
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Analyze how much revenue was generated from transactions where a discount was applied compared to those without discounts

SELECT Discount_Applied,
    CASE 
        WHEN Discount_Applied = 'Yes' THEN 'With_Discount'
        WHEN Discount_Applied = 'No' THEN 'Without_Discount'
        ELSE ''
    END AS Discount_Status,
       SUM(Purchase_Amount_USD) AS Total_Revenue
FROM transaction_table
GROUP BY Discount_Applied
ORDER BY Total_Revenue DESC;



-- Operational Bottlenecks

-- Determine which location has the most loyal customers based on their frequency of purchases

SELECT Location,
       COUNT(product_table.Frequency_of_Purchases)  AS Frequency_of_Purchases
FROM transaction_table
INNER JOIN product_table
ON 	transaction_table.Product_ID = product_table.Product_ID
GROUP BY Location
ORDER BY Location;

-- Find the most popular shipping type based on transaction count

SELECT TOP 1
       Shipping_Type,
       COUNT(Trans_ID) AS Transaction_Count
FROM transaction_table
GROUP BY Shipping_Type
ORDER BY Transaction_Count DESC;

/* Identify the correlation between item purchased, shipping type and review ratings by calculating the average review rating 
for each shipping type.Round the average rating to 2 decimal places */

SELECT Item_Purchased,
       transaction_table.Shipping_Type,
       ROUND(AVG(customer_table.Review_Rating), 2) AS Average_Review_Rating
FROM product_table
RIGHT JOIN transaction_table
ON product_table.Product_ID = transaction_table.Product_ID
LEFT JOIN customer_table
ON product_table.Product_ID = customer_table.Product_ID
GROUP BY Shipping_Type, Item_Purchased
ORDER BY Average_Review_Rating DESC;

-- List the top 3 seasons that generated the highest sales revenue
SELECT TOP 3
	   product_table.Season,
	   SUM(Purchase_Amount_USD) AS Sales_Revenue
FROM transaction_table
INNER JOIN product_table
ON transaction_table.Product_ID=product_table.Product_ID
GROUP BY Season
ORDER BY Sales_Revenue DESC;

-- Query to find the top 3 products, sizes and colors in demand based on total sales

SELECT TOP 3
	   Item_Purchased, Size, Color,
	   SUM(transaction_table.Purchase_Amount_USD) AS Total_Sales
FROM transaction_table
LEFT JOIN product_table
ON transaction_table.Product_ID = product_table.Product_ID
GROUP BY Item_Purchased, Size, Color
ORDER BY Total_Sales DESC;

-- Rank all products by the total revenue generated and provide the top 5 products for each season

WITH Product_Revenue AS (
	SELECT product_table.Product_ID,
	       Item_Purchased, Season,
	       SUM(transaction_table.Purchase_Amount_USD) AS Total_Revenue
	FROM product_table
    FULL OUTER JOIN transaction_table
    ON product_table.product_ID = transaction_table.Product_ID
    GROUP BY product_table.Product_ID, Item_Purchased, Season
),
Rank_Products AS (
	SELECT Product_ID,
	       Item_Purchased,
	       Season,
               Total_Revenue,
    RANK() OVER (PARTITION BY Season ORDER BY Total_Revenue DESC) AS Product_Rank
    FROM Product_Revenue
)
SELECT Product_ID,
       Item_Purchased, Season, Product_Rank, Total_Revenue
FROM Rank_Products
WHERE Product_Rank <= 5
ORDER BY Season, Product_Rank;















































