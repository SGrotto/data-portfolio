-- This query reads the Paris Airbnb listings and summary review datasets to assess the reasons prices are missing 

-- Assumption: unpriced listings are inactive. Inactive means likely no reviews.
-- Task 1: are unreviewed listings also unpriced?

-- New tool: cross-tabulation
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
categories AS (
SELECT
    CASE 
        WHEN l.price IS NULL THEN 'no price'
        ELSE 'priced'
    END AS price_status,
    CASE 
        WHEN r.listing_id IS NULL THEN 'no review'
        ELSE 'reviewed'
    END AS review_status 
FROM 'data/raw/listings.csv.gz' AS l
LEFT JOIN reviews_per_listing AS r
    ON l.id = r.listing_id
)
SELECT 
    price_status,
    review_status,
    COUNT(*) AS n 
FROM categories
GROUP BY price_status, review_status;

-- Question: are unreviewed listings also unpriced?
-- Results:
-- The absence of review can't be the only reason prices are missing. 
-- Our evidence lies in the fact that listings without reviews are more often unpriced (52% against 42% for listings with review(s))
-- It shows the link between reviews and unpriced listings exist, but it is weak.
-- Looking at the presence or absence of review can be limited, since a listing might have received a review in 2019 
-- but has no price at the time data on prices were collected, say in September 2026. Dates of the last reviews received should be explored.


-- Question: are unpriced listings dormant?
-- Results:
-- The data supports the idea that unpriced listings are dormants.
-- Listings with no price received much less recent reviews (past 12 months) than with a price: 38% vs 85%.
-- That still leaves open the question of the 38% unpriced but recently reviewed listings (9,750). It might be 
-- that these were fully booked or closed at scrape time, but must be checked against the calendar file. 

-- New tool: dates 

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
categories AS (
SELECT
    r.date_last_review,
    CASE 
        WHEN l.price IS NULL THEN 'no price'
        ELSE 'priced'
    END AS price_status,
    CASE 
        WHEN r.listing_id IS NULL THEN 'no review'
        ELSE 'reviewed'
    END AS review_status 
FROM 'data/raw/listings.csv.gz' AS l
LEFT JOIN reviews_per_listing AS r
    ON l.id = r.listing_id
)
SELECT 
    price_status,
    COUNT(*) AS n,
    ROUND(AVG(CASE WHEN date_last_review >= DATE '2025-09-16' THEN 1 ELSE 0 END), 2) AS share_last_review_post_160925
FROM categories
WHERE review_status = 'reviewed'
GROUP BY price_status;

