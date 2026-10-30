-- This file compares prices of listings during the Olympics and before/after it

-- Question: were the listings reviewed during the Olympics (26 July to 11 August 2024) different from the others, for example in price?

-- Count the listings reviewed during the Olympics period, using IN.
SELECT
    COUNT(*) AS n 
FROM 'data/clean/listings_clean.parquet'
WHERE id IN (
    SELECT listing_id
    FROM 'data/raw/reviews.csv'
    WHERE date BETWEEN DATE '2024-07-26' AND DATE '2024-08-11'
);              

-- Write one query that returns, for priced entire homes, two rows, “reviewed during the Olympics” and
--  “not reviewed during the Olympics”, with the number of listings and the median price of each. 
-- Hint: a CASE WHEN id IN (...) builds the group

WITH cte AS (
    SELECT id, price_eur,
        CASE 
            WHEN id IN 
                (SELECT listing_id FROM 'data/raw/reviews.csv' WHERE date BETWEEN DATE '2024-07-26' AND DATE '2024-08-11')
                THEN 'reviewed during the Olympics'
            ELSE 'not reviewed during the Olympics'
        END AS review_status
    FROM 'data/clean/listings_clean.parquet'
    WHERE 
        room_type='Entire home/apt' 
        AND price_eur IS NOT NULL 
        AND id IN (SELECT listing_id FROM 'data/raw/reviews.csv')
)
SELECT 
    review_status,
    COUNT(*) AS n, 
    ROUND(MEDIAN(price_eur),2) AS median_price
FROM cte
GROUP BY review_status;

-- This doesn’t tell us how prices behaved during the Olympics. 
-- Listings reviewed during the Games charge 252 euros today against 213 for other reviewed entire homes, but these are September 2026 prices, not 2024 ones. 
-- It suggests these listings are simply pricier, perhaps more central, which I’d check by comparing their neighbourhoods.