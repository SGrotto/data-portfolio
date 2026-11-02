-- Drill 4: How many hosts have 1 listing, 2 to 5 listings, and more than 5? Three rows, with the number of hosts in each band. 
-- Use the raw listings file for host_id. Hint: count listings per host first, then group the hosts into bands
WITH temp1 AS (
SELECT 
    COUNT(*) AS n_listings_by_host
FROM 'data/raw/listings.csv.gz'
GROUP BY host_id 
),
temp2 AS (
SELECT 
    CASE 
        WHEN n_listings_by_host=1 THEN '1 listing'
        WHEN n_listings_by_host>=2 AND n_listings_by_host<=5 THEN '2 to 5 listings'
        ELSE '6 or more'
    END AS category
FROM temp1
)  
SELECT 
    category,
    COUNT(*) AS n
FROM temp2
GROUP BY category
ORDER BY category; 
-- 13min. This is because I initially named "category" as "group", and duckdb constantly showed a synthax error so it turns out "group" can't be used for that purpose


-- Drill 5: For 2025, return each month, its number of reviews, and the running total since January. 
-- A running total is a window function with an order instead of a partition: SUM(...) OVER (ORDER BY ...).
SELECT 
    month(date) AS month,
    COUNT(*) AS n_reviews, 
    SUM(COUNT(*)) OVER (ORDER BY month(date)) AS running_total
FROM 'data/raw/reviews.csv'
WHERE year(date)=2025
GROUP BY month(date)
ORDER BY month(date);
-- 3min20

-- Drill 6: For 2025, return each month, its number of reviews, and the change from the previous month. 
-- New function: LAG(x) OVER (ORDER BY ...) returns the value of x on the previous row, so x - LAG(x) OVER (ORDER BY month) is the change. 
-- January’s change will be NULL, since there’s no previous row; that’s expected.
SELECT 
    month(date) AS month,
    COUNT(*) AS n_reviews, 
    COUNT(*)-LAG(COUNT(*)) OVER (ORDER BY month(date)) AS lag
FROM 'data/raw/reviews.csv'
WHERE year(date)=2025
GROUP BY month(date)
ORDER BY month(date);
-- 3min22


-- Drill 7: Extend Drill 6: add the month-over-month change in percent, rounded to 1 decimal. January is NULL.
SELECT 
    month(date) AS month,
    COUNT(*) AS n_reviews, 
    COUNT(*)-LAG(COUNT(*)) OVER (ORDER BY month(date)) AS change_vs_prev_month,
    ROUND(100*(COUNT(*)-(LAG(COUNT(*)) OVER (ORDER BY month(date))))/COUNT(*),1) AS perc_change_vs_prev_month
FROM 'data/raw/reviews.csv'
WHERE year(date)=2025
GROUP BY month(date)
ORDER BY month(date);
-- 6min31 

-- Drill 8: For each neighbourhood, what share of listings had at least one review in 2025? 
-- One row per neighbourhood, share rounded to 2 decimals, sorted from highest to lowest. Read listings from the clean table.
WITH temp AS (
SELECT listing_id
FROM 'data/raw/reviews.csv'
WHERE year(date)=2025
GROUP BY listing_id
)
SELECT 
    l.neighbourhood_cleansed AS neighbourhood,
    ROUND(COUNT(r.listing_id)/COUNT(*),2) AS share_at_least_1r_2025
FROM 'data/clean/listings_clean.parquet' AS l 
LEFT JOIN temp AS r 
ON l.id = r.listing_id
GROUP BY l.neighbourhood_cleansed
ORDER BY share_at_least_1r_2025 DESC;
-- 10m30: got stuck on conceptualizing the question 
