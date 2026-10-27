-- This query explore recently reviewed listings without a price using the column 

-- Analysis 
-- Question: why do 9,750 listings with a review in the past year have no price?
-- Hypothesis: they had no available nights when the data was collected, being fully booked or blocked by the host, so Airbnb displayed no price.
-- Proxy: availability_365, a column already in the listings file: the number of nights available over the next 365 days at scrape time.

WITH 
reviews_per_listing AS (
SELECT
    listing_id,
    COUNT(*) AS n_reviews,
    MIN(date) AS date_first_review,
    MAX(date) AS date_last_review
FROM 'data/raw/reviews.csv'
GROUP BY listing_id
),
data_last_review_12m AS (
SELECT 
    l.price_eur,
    CASE 
        WHEN l.price_eur IS NULL THEN 'no price'
        ELSE 'priced'
    END AS price_status,
    l.availability_365,
    r.date_last_review
FROM 'data/clean/listings_clean.parquet' AS l
INNER JOIN reviews_per_listing AS r
    ON l.id = r.listing_id
)

SELECT 
    price_status,
    COUNT(*) AS n,
    MEDIAN(availability_365) AS median_availability_365,
    ROUND(AVG(CASE WHEN availability_365 = 0 THEN 1 ELSE 0 END),2) AS share_no_availibility
FROM data_last_review_12m
WHERE date_last_review >= DATE '2025-09-16'
GROUP BY price_status;

-- Three-sentence version of the interpretation: 
-- Most recently reviewed listings without a price simply had no available nights when the data was collected. 
-- 59% of them show zero availability over the next year, against 2% of priced listings. 
-- The data can’t tell whether these nights were booked or blocked by the host, and about 4,000 unpriced listings remain unexplained