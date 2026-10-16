-- This query reads the Paris Airbnb listings dataset to test the unbookable-price hypothesis


-- Query 

WITH 
clean AS (
    SELECT
        id,
        number_of_reviews_ltm,
        CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE) AS price_eur
    FROM 'data/raw/listings.csv.gz'
),
grouped AS (
    SELECT
        *,
        CASE
            WHEN price_eur IS NULL THEN 'no price'
            WHEN price_eur >= 1000 THEN '1000+'
            ELSE 'under 1000'
        END AS price_group,
    FROM clean
)
SELECT 
    price_group,
    COUNT(*) AS n_listings,
    MEDIAN(number_of_reviews_ltm) AS median_review_ltm,
    ROUND(AVG(CASE WHEN number_of_reviews_ltm = 0 THEN 1 ELSE 0 END), 2) AS share_0_review_last_12_months
FROM grouped 
GROUP BY price_group
ORDER BY n_listings DESC;

-- Comments

-- 1. This query tests the hypothesis of listings with prices set intentionally way higher than their market value by their hosts to make them unbookable.
-- 2. We first define "high prices" with an arbitrary threshold of 1,000€, ensuring to isolate missing prices in the output. This gives three categories: "1000+", "under 1000" and "no price".
-- 3. Results: 
--      - 41,959 listings have a price < 1000€ (58%), among which 28% with no review in a year
--      - 1,578 listings have a price >= 1000€ (2%), among which 61% with no review in a year
--      - 33,612 listings have a missing price (40%), among which 71% with no review in a year
-- 4. Interpretation: the data is consistent with the hypothesis, but other explanations fit too:
--      - New listings have had no time to collect reviews, whatever their price.
--      - Genuine luxury listings are rarely booked simply because few people pay 1,000 euros a night.
--      The high share (71%) of listings without a price suggests that a large part of the dataset may be inactive listings. 
