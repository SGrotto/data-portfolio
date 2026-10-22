-- This query reads the Paris Airbnb listings and summary review datasets to assess the reasons prices are missing 

-- Question: why are 44% of prices missing?
-- Hypothesis: those listings are inactive.
-- Problem: activity isn’t a column in the data, so we can’t observe it directly.
-- Proxy: reviews. A listing that gets reviewed is being booked, so reviews stand in for activity.

-- Question 1: are unreviewed listings also unpriced?
-- Results:
-- Inactivity, measured as having no review at all, explains missing prices only weakly.
-- Unreviewed listings are unpriced slightly more often: 52% against 42% for reviewed ones.
-- "Any review ever" is a crude proxy: a listing reviewed in 2019 may be inactive today. Recent reviews are a better measure (query 2).

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


-- Question 2: are unpriced listings dormant?
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

