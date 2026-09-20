Q1 Profile the table: row count, distinct customers, distinct products, min and max order date
    
SELECT count(*) AS setir_sayi, count(DISTINCT "Customer ID") as unikal_mushteriler,
count(DISTINCT "Product ID") as unikal_nomreler, MIN("Order Date") as min_tarix,
MAX("Order Date") as max_tarix
FROM orders;

Q2 NULL count for every column (one row per column, or a single row with one COUNT per column)

SELECT COUNT(*) - COUNT("row id") AS column_1,
	   COUNT(*) - COUNT("order id") AS column_2,
	   COUNT(*) - COUNT("order date") AS column_3,
	   COUNT(*) - COUNT("Ship Date") AS column_4,
	   COUNT(*) - COUNT("Ship Mode") AS column_5,
	   COUNT(*) - COUNT("Customer ID") AS column_6,
	   COUNT(*) - COUNT("Customer Name") AS column_7,
	   COUNT(*) - COUNT("Segment") AS column_8,
	   COUNT(*) - COUNT("Country") AS column_9,
	   COUNT(*) - COUNT("City") AS column_10,
	   COUNT(*) - COUNT("State") AS column_11,
	   COUNT(*) - COUNT("Postal Code") AS column_12,
	   COUNT(*) - COUNT("Region") AS column_13,
	   COUNT(*) - COUNT("Product ID") AS column_14,
	   COUNT(*) - COUNT("Category") AS column_15,
	   COUNT(*) - COUNT("Sub-Category") AS column_16,
	   COUNT(*) - COUNT("Product Name") AS column_17,
	   COUNT(*) - COUNT("Sales") AS column_18,
	   COUNT(*) - COUNT("Quantity") AS column_19,
	   COUNT(*) - COUNT("Discount") AS column_20,
	   COUNT(*) - COUNT("Profit") AS column_21
FROM orders;
Q3 Detect duplicate order lines: GROUP BY the natural key and HAVING COUNT(*) > 1

SELECT 
    "Order ID", 
    "Product ID", 
    COUNT(*) AS line_count
	FROM orders
	GROUP BY "Order ID", "Product ID"
	HAVING count(*) > 1;


Q4 Average days_to_ship per Ship Mode, using SQL date arithmetic (SQLite: julianday(ship_date) - julianday(order_date))

SELECT 
    "Ship Mode",
    ROUND(AVG(julianday("Ship Date") - julianday("Order Date")), 2) AS ortalama_catdirilma_gunu
FROM orders
GROUP BY "Ship Mode"
ORDER BY ortalama_catdirilma_gunu ASC;

Q5 SUM(Sales), SUM(Profit) and profit margin (Profit/Sales) grouped by Region, Category and Sub-Category, ordered by profit ascending

SELECT 
    "Region",
    "Category",
    "Sub-Category",
    ROUND(SUM("Sales"), 2) AS umumi_satislar,
    ROUND(SUM("Profit"), 2) AS umumi_menfeet,
    ROUND(SUM("Profit") / SUM("Sales"), 4) AS menfeet_marjasi
FROM orders
GROUP BY "Region", "Category", "Sub-Category"
ORDER BY umumi_menfeet ASC;
    
Q6 Top 5 and bottom 5 Sub-Categories by total profit in a single result set (UNION ALL of two ordered subqueries, or RANK() in a CTE)
WITH SiralanmisAltKateqoriyalar AS (
    SELECT 
        "Sub-Category" AS alt_kateqoriya,
        ROUND(SUM("Profit"), 2) AS umumi_menfeet,
        RANK() OVER (ORDER BY SUM("Profit") DESC) AS sira_yuxari,
        RANK() OVER (ORDER BY SUM("Profit") ASC) AS sira_asagi
    FROM orders
    GROUP BY "Sub-Category"
)
SELECT 
    alt_kateqoriya, 
    umumi_menfeet, 
    'En Yuksek 5' AS qrup_novu
FROM SiralanmisAltKateqoriyalar
WHERE sira_yuxari <= 5
UNION ALL
SELECT 
    alt_kateqoriya, 
    umumi_menfeet, 
    'En Asagi 5' AS qrup_novu
FROM SiralanmisAltKateqoriyalar
WHERE sira_asagi <= 5
ORDER BY umumi_menfeet DESC;
    
Q7 Discount bands via CASE WHEN (0, 1-20%, 21-40%, 41%+) with order count, avg profit and total profit per band

SELECT CASE 
       WHEN "Discount" = 0 THEN '0% Endirim Yoxdur'
       WHEN "Discount" > 0 AND "Discount" <= 0.20 THEN '1-20% Az Endirim'
       WHEN "Discount" > 0.20 AND "Discount" <= 0.40 THEN '21-40% Orta Endirim'
       ELSE '41%+ Yuksek Endirim'
    END AS endirim_qrupu,
    COUNT(*) AS umumi_sifaris_sayi,
    ROUND(SUM("Sales"), 2) AS umumi_satis,
    ROUND(SUM("Profit"), 2) AS umumi_menfeet,
    ROUND(AVG("Profit"), 2) AS ortalama_menfeet
FROM orders
GROUP BY endirim_qrupu
ORDER BY ortalama_menfeet DESC;
Q8 Total sales per year with YoY absolute and percentage change using LAG()

    WITH IllikSatislar AS (
    SELECT 
    STRFTIME('%Y', "Order Date") AS satis_ili,
    ROUND(SUM("Sales"), 2) AS umumi_satis
    FROM orders
    GROUP BY satis_ili
)
SELECT 
    satis_ili,
    umumi_satis,
    LAG(umumi_satis, 1) OVER (ORDER BY satis_ili) AS evvelki_il_satis,
    ROUND(((umumi_satis - LAG(umumi_satis, 1) OVER (ORDER BY satis_ili)) / LAG(umumi_satis, 1) OVER (ORDER BY satis_ili)) * 100,2) AS illik_artim_faizi
FROM IllikSatislar;
    
Q9 Sub-categories with negative total profit, and the share of total revenue they represent

WITH ZererEdenler AS (
    SELECT 
        "Sub-Category" AS alt_kateqoriya,
        SUM("Sales") AS alt_satis,
        SUM("Profit") AS zerer_meblegi
    FROM orders
    GROUP BY "Sub-Category"
    HAVING SUM("Profit") < 0
)
SELECT alt_kateqoriya,
       ROUND(alt_satis, 2) AS satis,
       ROUND(zerer_meblegi, 2) AS zerer_meblegi,
       ROUND((alt_satis / (SELECT SUM("Sales") FROM orders)) * 100, 2) AS gelirdeki_payi_faizle
FROM ZererEdenler
ORDER BY zerer_meblegi ASC;

Q10 Top 10 customers by lifetime profit, with their order count and average order value

SELECT 
    "Customer ID" AS musteri_id,
    "Customer Name" AS musteri_adi,
    COUNT(DISTINCT "Order ID") AS umumi_sifaris_sayi,
    ROUND(SUM("Sales"), 2) AS umumi_satis,
    ROUND(SUM("Profit"), 2) AS lifetime_menfeet,
    ROUND(AVG("Sales"), 2) AS ortalama_sifaris_deyeri
FROM orders
GROUP BY "Customer ID", "Customer Name"
ORDER BY lifetime_menfeet DESC
LIMIT 10;