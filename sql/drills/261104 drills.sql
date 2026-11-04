-- Drill 18, latest record per entity (target 7 min). For each listing in the raw reviews file, keep only the row of its most recent review, using ROW_NUMBER(). 
-- Return the number of rows you get, and check it against a number you already know.

WITH temp AS (
SELECT 
    listing_id,
    ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY date DESC) AS rn 
FROM 'data/raw/reviews.csv'
)
SELECT 
    COUNT(*) AS n_listings 
FROM temp 
WHERE rank=1;

-- 2min23 - 61,753 is the number of unique listings recorded in the review file and that merge the listing file

-- Drill 19, stacking results (target 7 min). UNION ALL stacks the rows of two queries with the same columns, one under the other:
-- Return a two-column table with three rows: the number of listings, the number of distinct listings with at least one review, and the number of reviews.

SELECT 
    'Number of listings' AS metric,
    COUNT(*) AS value 
FROM 'data/clean/listings_clean.parquet'
UNION ALL 
SELECT 
    'Number of distinct listings with at least one review' AS metric,
    COUNT(DISTINCT listing_id) AS count
FROM 'data/raw/reviews.csv'
UNION ALL 
SELECT 
    'Number of reviews' AS metric,
    COUNT(*) AS count
FROM 'data/raw/reviews.csv';

-- 7min30: out of time; I didn't get why you asked for a two-columns table: is the first supposed to be what each row represent (e.g. first row "Total number of listings")? Because as it is now, the figures don't tell much to a reader. If so, how to do?


-- Drill 20, percentiles (target 8 min). QUANTILE_CONT(x, 0.9) returns the 90th percentile of x. 
-- For priced listings, return for each room_type the 10th percentile, the median and the 90th percentile of price_eur.

SELECT 
    room_type,
    ROUND(QUANTILE_CONT(price_eur, 0.1),2) AS percentile_10,
    ROUND(MEDIAN(price_eur),2) AS median,
    ROUND(QUANTILE_CONT(price_eur, 0.9),2) AS percentile_90
FROM 'data/clean/listings_clean.parquet'
WHERE price_eur IS NOT NULL 
GROUP BY room_type
ORDER BY room_type;
-- 2min44


-- Drill 21, anti-join (target 6 min). Count the listings that never received a review, in two ways:
--1.
SELECT 
    COUNT(*) AS unreviewed_listings 
FROM 'data/clean/listings_clean.parquet' AS l 
LEFT JOIN 'data/raw/reviews.csv' AS r
ON l.id = r.listing_id
WHERE r.listing_id IS NULL ;
--2.
SELECT 
    COUNT(*) AS unreviewed_listings 
FROM 'data/clean/listings_clean.parquet' 
WHERE id NOT IN (
    SELECT listing_id FROM 'data/raw/reviews.csv' 
);
--3min 

-- Drill 22, the second highest (target 8 min). For each neighbourhood, return the second highest price among priced entire homes.
WITH temp AS (
SELECT 
    neighbourhood_cleansed, price_eur,
    DENSE_RANK() OVER (PARTITION BY neighbourhood_cleansed ORDER BY price_eur DESC) AS rn 
FROM 'data/clean/listings_clean.parquet' 
WHERE room_type = 'Entire home/apt' AND price_eur IS NOT NULL
)
SELECT 
    neighbourhood_cleansed, price_eur 
FROM temp 
WHERE rn=2
ORDER BY neighbourhood_cleansed, rn ;
-- 4min58 : seems like no entire homes/apt listings have the same second highest price 

-- Drill 23, concentration (target 12 min). A classic business question: what share of all listings belongs to the top 1% of hosts, ranked by number of listings? 
-- Return one number.

WITH temp AS (
SELECT 
    host_id,
    COUNT(*) AS n_listings
FROM 'data/raw/listings.csv.gz'
GROUP BY host_id 
),
temp2 AS (
SELECT 
    host_id,
    n_listings,
    SUM(n_listings) OVER () AS total_listings,
    ROW_NUMBER() OVER (ORDER BY n_listings DESC) AS rn 
FROM temp 
)
SELECT 
    ROUND(SUM(n_listings)/MAX(total_listings),4) AS share 
FROM temp2
WHERE (rn <= 0.01 * (SELECT COUNT(DISTINCT host_id) FROM 'data/raw/listings.csv.gz'));
--14min20 - not sure about this one. I know I've used a MAX() in a way you don't like but I was running out of time
