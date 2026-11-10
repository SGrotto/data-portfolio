-- Problem 1. For each neighbourhood, the share of priced listings that are entire homes for at least 4 guests. 
-- Keep only neighbourhoods where that share is above 0.30. Rounded to 2 decimals, sorted from highest to lowest.
WITH cte1 AS (
SELECT 
    neighbourhood_cleansed,
    AVG(CASE WHEN room_type = 'Entire home/apt' AND accommodates>=4 THEN 1 ELSE 0 END) AS share 
FROM 'data/clean/listings_clean.parquet'
WHERE price_eur IS NOT NULL 
GROUP BY neighbourhood_cleansed
)
SELECT * FROM cte1 WHERE ROUND(share,3)>0.3 ORDER BY share DESC;
-- 8min

-- Problem 2. How many hosts have listings in exactly one neighbourhood, and how many in two or more? 
-- Two rows: a label and the number of hosts. Use the raw listings file.
WITH cte1 AS (
SELECT 
    host_id,
    COUNT(DISTINCT neighbourhood_cleansed) AS distinct_neighbour
FROM 'data/raw/listings.csv.gz'
GROUP BY host_id
),
cte2 AS (
SELECT
    CASE WHEN distinct_neighbour=1 THEN 'Exactly one neighbourhood'
    ELSE 'Two or more neighbourhoods' 
    END AS label
FROM cte1 
)
SELECT label COUNT(*) FROM cte2 GROUP BY label;
-- 20min15

-- Problem 3. For each neighbourhood, the 2 cheapest priced entire homes among those with at least 10 reviews in the last 12 months: 
-- neighbourhood, id, price. Sorted by neighbourhood, then price.
WITH cte1 AS (
SELECT 
    neighbourhood_cleansed, price_eur, id,
    ROW_NUMBER() OVER (PARTITION BY neighbourhood_cleansed ORDER BY price_eur ASC) AS price_rank 
FROM 'data/clean/listings_clean.parquet'
WHERE room_type = 'Entire home/apt' AND price_eur IS NOT NULL AND number_of_reviews_ltm>=10
)
SELECT 
    neighbourhood_cleansed, id, price_eur 
FROM cte1 
WHERE price_rank<=2
ORDER BY neighbourhood_cleansed, price_eur ;
--27min

-- Problem 4. Using each listing’s first review as its entry year: for each year from 2015 to 2025, the number of new listings, 
-- the cumulative number of new listings since 2015, and each year’s share of all new listings over 2015–2025, rounded to 3 decimals. 
-- The cumulative total must start at 2015, not before.
WITH cte1 AS (
SELECT 
    listing_id, date,
    ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY date) AS date_rank,
FROM 'data/raw/reviews.csv'
),
cte2 AS (
SELECT *, COUNT(*) OVER () AS n_total FROM cte1 WHERE date_rank=1 AND year(date) BETWEEN 2015 AND 2025
)
SELECT 
    year(date) AS year_review,
    COUNT(*) AS n_new_listings,
    SUM(COUNT(*)) OVER (ORDER BY year(date)) AS cumulative_new_listings,
    ROUND(COUNT(*)/MAX(n_total),3) AS share_over_2015_2025
FROM cte2 
GROUP BY year(date)
ORDER BY year_review; 
--42min

-- Problem 5. Among listings reviewed in both 2024 and 2025, how many received more reviews in 2025 than in 2024? Return one number.
WITH per_listing AS (
    SELECT
        listing_id,
        SUM(CASE WHEN year(date) = 2024 THEN 1 ELSE 0 END) AS n_2024,
        SUM(CASE WHEN year(date) = 2025 THEN 1 ELSE 0 END) AS n_2025
    FROM 'data/raw/reviews.csv'
    WHERE year(date) IN (2024, 2025)
    GROUP BY listing_id
)
SELECT COUNT(*) AS n_listings
FROM per_listing
WHERE n_2024 > 0 AND n_2025 > n_2024;
--45min47
