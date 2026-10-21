-- This query reads the Paris Airbnb listings dataset to try WHERE and HAVING in SQL


-- Task: write a query that returns, for each neighbourhood, the number of priced listings and the median price_eur, 
-- only for entire homes with a price, and keeps only neighbourhoods with at least 1,000 priced entire homes. 
-- Sort from most to least expensive.

-- Query: 

WITH clean AS (
    SELECT
        id,
        neighbourhood_cleansed,
        room_type,
        CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE) AS price_eur
    FROM 'data/raw/listings.csv.gz'
)

SELECT
    neighbourhood_cleansed,
    COUNT(*) AS count_priced_listings,
    ROUND(MEDIAN(price_eur),2) AS price_median
FROM clean
WHERE room_type='Entire home/apt' AND price_eur IS NOT NULL
GROUP BY neighbourhood_cleansed
HAVING COUNT(*) >= 1000
ORDER BY price_median DESC;

-- Comments

-- 1. Élysée has the highest median and is therefore the most expensive neighbourhoods, approximately 127% more than the cheapest one shown (351.75€ compared to 155€), Ménilmontant.
-- 2. Three filters have been applied: (i) entire homes/apartments (ii) non-missing prices (iii) neighbourhoods with at least 1000 listings.
--      - The first two have been placed in WHERE, as they filter for rows without refering to calculations
--      - The third one is in HAVING, as it filters according to the result of a calculation (COUNT). Note that it did not exclude any neighbourhood in this snapshot.
--        It is added to make sure neighbourhood with few listings are excluded. Why? While median protects against extreme values, they don't protect against small samples.
-- 3. As original prices are text, they must be converted, which is done in the CTE at the beginning of the query.
