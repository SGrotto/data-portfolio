-- Drill 9 (target 7 min). For each room_type, the median number of reviews, counting listings with no review as 0. 
-- Use the clean table, your reviews_per_listing CTE, and a LEFT JOIN.
-- New function: COALESCE(x, 0) returns x, or 0 when x is NULL. In Stata terms, replace x = 0 if missing(x), done inside the query.
-- Give two medians per room type: one with COALESCE, one without, to see the difference.

WITH 
reviews_per_listing AS (
SELECT
    listing_id,
    COUNT(*) AS n_reviews,
    MIN(date) AS date_first_review,
    MAX(date) AS date_last_review
FROM 'data/raw/reviews.csv'
GROUP BY listing_id
)
SELECT 
    l.room_type,
    MEDIAN(r.n_reviews) AS median_no_coalesce,
    MEDIAN(COALESCE(n_reviewsr.,0)) AS median_using_coalesce
FROM 'data/clean/listings_clean.parquet' AS l 
LEFT JOIN reviews_per_listing AS r
ON l.id = r.listing_id
GROUP BY l.room_type 
ORDER BY l.room_type;
-- 7min30: worth noting medians are much higher without coalesce - expected as coalesce integrates the 15,396 unreviewed listings in the calculations with 0 review, making the median going down


-- Drill 10 (target 6 min). Finding duplicates, a very common interview task. In the raw reviews file, how many (listing_id, date) pairs appear more than once? Return one number. 
-- Hint: group by both columns, keep groups with more than one row, then count them.

SELECT COUNT(*) AS n_pair_duplicates
FROM (
    SELECT listing_id, date
    FROM 'data/raw/reviews.csv'
    GROUP BY listing_id, date
    HAVING COUNT(*) > 1
);
-- 3min53

-- Drill 11

SELECT 
    COUNT(*) AS n
FROM 'data/clean/listings_clean.parquet' AS a 
JOIN 'data/clean/listings_clean.parquet' AS b
ON a.price_eur = b.price_eur AND a.id < b.id
WHERE a.room_type='Entire home/apt' AND a.price_eur IS NOT NULL AND a.neighbourhood_cleansed='Élysée'
AND b.room_type='Entire home/apt' AND b.price_eur IS NOT NULL AND b.neighbourhood_cleansed='Élysée';

-- OR 

WITH elysee AS (
    SELECT id, price_eur
    FROM 'data/clean/listings_clean.parquet'
    WHERE room_type = 'Entire home/apt'
      AND neighbourhood_cleansed = 'Élysée'
      AND price_eur IS NOT NULL
)
SELECT COUNT(*) AS n_pairs
FROM elysee AS a
JOIN elysee AS b
    ON a.price_eur = b.price_eur AND a.id < b.id;

--7min22


-- Drill 12:
-- Drill 12, funnel (target 8 min). Funnels show how many items survive each step. In one row, using the clean table, return:
    -- all listings
    -- listings with a price
    -- of those, listings with availability_365 > 0
    -- of those, listings with number_of_reviews_ltm > 0
-- Then add, for each step after the first, its share of the previous step, rounded to 2 decimals. Hint: conditional aggregation, as in last week’s months × years table.

WITH steps AS (
    SELECT
        COUNT(*) AS n_all,
        COUNT(price_eur) AS n_priced,
        SUM(CASE WHEN price_eur IS NOT NULL AND availability_365 > 0 THEN 1 ELSE 0 END) AS n_available,
        SUM(CASE WHEN price_eur IS NOT NULL AND availability_365 > 0
                  AND number_of_reviews_ltm > 0 THEN 1 ELSE 0 END) AS n_reviewed
    FROM 'data/clean/listings_clean.parquet'
)
SELECT
    n_all, n_priced, n_available, n_reviewed,
    ROUND(n_priced / n_all, 2) AS share_priced,
    ROUND(n_available / n_priced, 2) AS share_available,
    ROUND(n_reviewed / n_available, 2) AS share_reviewed
FROM steps;
-- 10min50


-- Drill 13 (target 6 min). Count listings by bathroom band: '0', '0.5 to 1', '1.5 to 2', 'more than 2', and 'unknown' for missing values. 
-- Use the clean table. Make sure the 49 missing values land in 'unknown' rather than disappearing.
WITH temp AS (
SELECT 
    n_bathrooms,
    CASE 
        WHEN n_bathrooms=0 THEN '0'
        WHEN n_bathrooms BETWEEN 0.5 AND 1 THEN '0.5 to 1'
        WHEN n_bathrooms BETWEEN 1.5 AND 2 THEN '1.5 to 2'
        WHEN n_bathrooms>2 THEN 'more than 2'
        WHEN n_bathrooms IS NULL THEN 'unknown'
        ELSE 'check'
    END AS bathroom_category
FROM 'data/clean/listings_clean.parquet'
)
SELECT 
    bathroom_category,
    COUNT(*) AS n_listings
FROM temp
GROUP BY bathroom_category
ORDER BY bathroom_category;
--6min38

-- Drill 14 (target 8 min). Among priced listings, which 3 neighbourhoods have the highest share of entire homes? Return the neighbourhood, 
-- the number of priced listings, and the share, rounded to 2 decimals.
SELECT 
    neighbourhood_cleansed, 
    COUNT(*) AS n_priced_listings,
    ROUND(SUM(CASE WHEN room_type='Entire home/apt' THEN 1 ELSE 0 END)/COUNT(*),2) AS share_priced_entirehomes
FROM 'data/clean/listings_clean.parquet'
WHERE price_eur IS NOT NULL 
GROUP BY neighbourhood_cleansed
ORDER BY share_priced_entirehomes DESC 
LIMIT 3;
-- 5min49

-- Drill 15 (target 10 min). “Time between events” is a classic interview pattern. In 2025, what is the median number of days between two consecutive reviews of the same listing? 
-- Return one number.

WITH temp AS (
SELECT 
    listing_id, date,
    date_diff('day', LAG(date) OVER (PARTITION BY listing_id ORDER BY date), date) AS date_delta
FROM 'data/raw/reviews.csv'
WHERE year(date)=2025
)
SELECT 
    MEDIAN(date_delta) AS median_days_2r
FROM temp;
-- 10min13


-- Drill 16 (target 8 min). How many hosts have listings in at least 3 different neighbourhoods? Return one number. Use the raw listings file.

WITH temp AS (
SELECT 
    host_id,
FROM 'data/raw/listings.csv.gz'
GROUP BY host_id
HAVING COUNT(DISTINCT neighbourhood_cleansed) >=3
)
SELECT 
    COUNT(*) AS n_hosts
FROM temp;

-- 20min

-- Drill 17 (target 10 min). For each neighbourhood, the median price of priced entire homes, and its difference from the Paris-wide median of priced entire homes. 
-- Sorted by the difference, highest first.

WITH temp as (
SELECT 
    id,
    neighbourhood_cleansed,
    MEDIAN(price_eur) OVER (PARTITION BY neighbourhood_cleansed) AS median_neighbour_temp,
    MEDIAN(price_eur) OVER () AS median_paris_temp
FROM 'data/clean/listings_clean.parquet'
WHERE room_type = 'Entire home/apt' AND price_eur IS NOT NULL
)
SELECT 
    neighbourhood_cleansed,
    MAX(ROUND(median_neighbour_temp,2)) AS median_neighbour,
    MAX(ROUND(median_paris_temp,2)) AS median_paris ,
    ROUND(median_neighbour-median_paris,2) AS diff_median
FROM temp 
GROUP BY neighbourhood_cleansed
ORDER BY diff_median DESC;

-- 11min