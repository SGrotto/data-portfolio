-- Problem 1. For each room_type with at least 500 priced listings: 
-- the number of priced listings and the median price, rounded to 2 decimals. Sorted by median price, highest first.
SELECT 
    room_type,
    COUNT(*) AS number_listings,
    ROUND(MEDIAN(price_eur),2) AS price_median 
FROM 'data/clean/listings_clean.parquet' 
WHERE price_eur IS NOT NULL 
GROUP BY room_type
HAVING COUNT(*)>=500
ORDER BY price_median DESC;
--3min10

-- Problem 2. For each neighbourhood: the number of listings, and the average number of reviews per listing, counting listings with no review as 0. 
-- Count reviews from reviews.csv, not from a column of the listings file. Rounded to 1 decimal, sorted from highest average to lowest.
WITH 
reviews_per_listing AS (
SELECT
    listing_id,
    COUNT(*) AS n_reviews
FROM 'data/raw/reviews.csv'
GROUP BY listing_id
)
SELECT 
    l.neighbourhood_cleansed,
    COUNT(*) AS number_listings,
    ROUND(AVG(COALESCE(r.n_reviews,0)),1) AS avg_n_reviews
FROM 'data/clean/listings_clean.parquet' AS l
LEFT JOIN reviews_per_listing AS r 
    ON l.id = r.listing_id
GROUP BY l.neighbourhood_cleansed
ORDER BY avg_n_reviews DESC;
-- 12min35 

-- Problem 3. For each room_type, the 3 hosts with the most listings of that room type: room_type, host_id, number of listings. 
-- If there’s a tie, keep any. Use the raw listings file.
WITH cte1 AS (
SELECT 
    room_type, host_id,
    COUNT(*) AS number_listings
FROM 'data/raw/listings.csv.gz'
GROUP BY room_type, host_id 
),
cte2 AS (
SELECT 
    room_type, host_id, number_listings,
    ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY number_listings DESC) AS rn
FROM cte1 
)
SELECT room_type, host_id, number_listings
FROM cte2 
WHERE rn<=3
ORDER BY room_type, number_listings DESC, host_id ;
-- 20min35


-- Problem 4. For each quarter of 2024 and 2025: the number of reviews, and the change in percent from the previous quarter, rounded to 1 decimal. 
-- The first quarter of 2024 must be compared with the last quarter of 2023, so it should not be empty.
WITH cte1 AS (
SELECT 
    COUNT(*) AS n_reviews,
    quarter(date) AS quarter_review,
    year(date) AS year_review
FROM 'data/raw/reviews.csv'
GROUP BY year(date), quarter(date) 
),
cte2 AS (
SELECT 
    year_review, quarter_review, n_reviews,
    ROUND(100*(n_reviews-LAG(n_reviews) OVER (ORDER BY year_review, quarter_review))/ LAG(n_reviews) OVER (ORDER BY year_review, quarter_review),1) AS n_listing_q_change 
FROM cte1 
)
SELECT * FROM cte2 WHERE year_review BETWEEN 2024 AND 2025 ORDER BY year_review, quarter_review;
--36min44 


-- Problem 5. Among listings with at least two reviews in 2025, how many had a gap of more than 90 days between two consecutive reviews in 2025? 
-- Return one number.
WITH cte1 AS (
SELECT 
    listing_id, date
FROM 'data/raw/reviews.csv'
WHERE listing_id IN (
        SELECT 
        listing_id
        FROM 'data/raw/reviews.csv'
        WHERE year(date)=2025
        GROUP BY listing_id
        HAVING COUNT(*)>=2
)
),
cte2 AS (
SELECT listing_id, date FROM cte1 WHERE year(date)=2025 
),
cte3 AS (
SELECT 
    listing_id,
    date-LAG(date) OVER (PARTITION BY listing_id ORDER BY date) AS review_lag 
FROM cte2 
)
SELECT COUNT(DISTINCT listing_id) AS distinct_listing_id FROM cte3 WHERE review_lag>90
-- 44min18