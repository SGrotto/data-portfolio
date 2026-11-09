-- Drill 24: For each room_type, what share of listings belongs to a host with more than 5 listings in total?
WITH temp AS (
SELECT 
host_id,
room_type,
COUNT(*) OVER (PARTITION BY host_id) AS count_by_hosts 
FROM 'data/raw/listings.csv.gz'
)
SELECT 
    room_type,
    ROUND(AVG(CASE WHEN count_by_hosts>5 THEN 1 ELSE 0 END),2) AS share_listings 
FROM temp 
GROUP BY room_type;
--13min58

-- Drill 25 (target 10 min). For each neighbourhood, which month of 2025 had the most reviews? One row per neighbourhood: neighbourhood, month, number of reviews.
WITH monthly AS (
    SELECT
        l.neighbourhood_cleansed,
        month(r.date) AS review_month,
        COUNT(*) AS n_reviews
    FROM 'data/raw/reviews.csv' AS r
    JOIN 'data/clean/listings_clean.parquet' AS l
        ON l.id = r.listing_id
    WHERE year(r.date) = 2025
    GROUP BY l.neighbourhood_cleansed, month(r.date)
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY neighbourhood_cleansed ORDER BY n_reviews DESC) AS rn
    FROM monthly
)
SELECT neighbourhood_cleansed, review_month, n_reviews
FROM ranked
WHERE rn = 1
ORDER BY neighbourhood_cleansed;

-- Drill 26 (target 8 min). Using each listing’s first review as a proxy for when it joined Airbnb: for each year from 2020 to 2025, 
-- how many listings had their first review that year, and what’s the change in percent from the previous year?

WITH first_reviews AS (
    SELECT listing_id, MIN(date) AS first_review
    FROM 'data/raw/reviews.csv'
    GROUP BY listing_id
),
per_year AS (
    SELECT year(first_review) AS first_year, COUNT(*) AS n_new
    FROM first_reviews
    GROUP BY year(first_review)
),
with_change AS (
    SELECT
        first_year,
        n_new,
        ROUND(100.0 * (n_new - LAG(n_new) OVER (ORDER BY first_year))
              / LAG(n_new) OVER (ORDER BY first_year), 1) AS pct_change
    FROM per_year
)
SELECT *
FROM with_change
WHERE first_year BETWEEN 2020 AND 2025
ORDER BY first_year;

-- Drill 27 (target 10 min). For each host with at least 10 listings, in which neighbourhood do they have the most listings? 
-- One row per host: host_id, neighbourhood, number of listings there. If there’s a tie, keep any one. Use the raw listings file.
WITH cte1 AS (
SELECT 
    host_id, neighbourhood_cleansed,
    COUNT(*) AS n_listings
FROM 'data/raw/listings.csv.gz' 
WHERE host_id IN (SELECT host_id FROM 'data/raw/listings.csv.gz' GROUP BY host_id HAVING COUNT(*)>=10)
GROUP BY host_id, neighbourhood_cleansed
),
cte2 AS (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY host_id ORDER BY n_listings DESC) AS ranked 
FROM cte1
)
SELECT host_id, neighbourhood_cleansed, n_listings
FROM cte2 
WHERE ranked=1
ORDER BY host_id;
--13min59 


-- Drill 28 (target 8 min). For each neighbourhood, what share of its 2025 reviews fell in July or August? Sorted from highest share to lowest, rounded to 3 decimals.
SELECT
    l.neighbourhood_cleansed,
    ROUND(AVG(CASE WHEN month(r.date) IN (7, 8) THEN 1 ELSE 0 END), 3) AS share_july_august
FROM 'data/raw/reviews.csv' AS r
JOIN 'data/clean/listings_clean.parquet' AS l
    ON l.id = r.listing_id
WHERE year(r.date) = 2025
GROUP BY l.neighbourhood_cleansed
ORDER BY share_july_august DESC;


-- Drill 29 (target 10 min). Among priced entire homes, how many listings in each neighbourhood cost more than 3 times their neighbourhood’s median? 
-- Sorted from most to fewest.
WITH cte1 AS (
SELECT 
    id,
    neighbourhood_cleansed,
    price_eur,
    MEDIAN(price_eur) OVER (PARTITION BY neighbourhood_cleansed) AS median_neighbour 
FROM 'data/clean/listings_clean.parquet' 
WHERE room_type = 'Entire home/apt' AND price_eur IS NOT NULL
)
SELECT 
    neighbourhood_cleansed,
    SUM(CASE WHEN price_eur > 3*median_neighbour THEN 1 ELSE 0 END) AS number_listings 
FROM cte1 
GROUP BY neighbourhood_cleansed
ORDER BY number_listings DESC;
-- 5min5