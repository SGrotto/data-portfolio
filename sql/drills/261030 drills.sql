-- Drill 1. Which 5 hosts have the most listings? 
-- Return host_id and the number of listings. (Use the raw listings file: host_id isn’t in your clean table.)
SELECT 
    host_id, MAX(host_name) AS name,
    COUNT(*) AS n_listings_by_host
FROM 'data/raw/listings.csv.gz'
WHERE host_id IS NOT NULL
GROUP BY host_id 
ORDER BY n_listings_by_host DESC 
LIMIT 5 ; 
-- 6m50

-- Drill 2. For each room_type, what share of listings has a price? One row per room type, share rounded to 2 decimals.
SELECT 
    room_type, 
    ROUND(AVG(CASE WHEN price_eur IS NOT NULL THEN 1 ELSE 0 END),2) AS share_priced_listing
FROM 'data/clean/listings_clean.parquet'
GROUP BY room_type
ORDER BY share_priced_listing DESC ;
-- 6m12

-- Drill 3. For each neighbourhood, which listing had the most reviews in the last 12 months? 
-- One row per neighbourhood: neighbourhood, id, number_of_reviews_ltm. If there’s a tie, keep any one.

WITH review AS (
SELECT
listing_id,
COUNT(*) AS n_reviews,
MIN(date) AS date_min
FROM 'data/raw/reviews.csv'
GROUP BY listing_id 
),
temp AS (
SELECT
    neighbourhood_cleansed, id, number_of_reviews_ltm, n_reviews,
    ROW_NUMBER() OVER (PARTITION BY neighbourhood_cleansed ORDER BY n_reviews DESC) AS rank_review
FROM 'data/clean/listings_clean.parquet' AS l 
INNER JOIN review AS r 
ON l.id = r.listing_id 
WHERE r.date_min >= DATE '2025-09-16'
) 
SELECT 
    neighbourhood_cleansed, id, number_of_reviews_ltm, n_reviews
FROM temp 
WHERE rank_review=1
ORDER BY number_of_reviews_ltm DESC;
-- 25min: it took me long because I recalculted number of reviews (I forgot the data already had it)