-- This query explores listings with outliers prices in the Paris Airbnb listings dataset 

-- Question 1: how expensive is each listing compared to its own neighbourhood? 
-- A 400-euro flat is expensive in Ménilmontant but ordinary in Élysée

-- Results:
-- The listings most overpriced relative to their neighbourhood are the same extreme prices found earlier. 
-- They cost 65 to 484 times their neighbourhood median, far beyond any plausible luxury premium. 
-- Since they’re likely the unbookable prices identified before, the ratio becomes informative only once they’re excluded.

-- New tool: OVER (PARTITION BY ...)
WITH clean AS (
    SELECT
        id,
        neighbourhood_cleansed,
        room_type,
        CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE) AS price_eur
    FROM 'data/raw/listings.csv.gz'
)
SELECT
    id,
    neighbourhood_cleansed,
    price_eur,
    ROUND(MEDIAN(price_eur) OVER (PARTITION BY neighbourhood_cleansed),2) AS median_price,
    ROUND(price_eur/(MEDIAN(price_eur) OVER (PARTITION BY neighbourhood_cleansed)),2) AS price_ratio
FROM clean
WHERE room_type='Entire home/apt' AND price_eur IS NOT NULL
ORDER BY price_ratio DESC
LIMIT 10;


-- Question 2: which are the 3 cheapest entire homes in each neighbourhood? Low prices may hide errors too
-- Results:
-- The cheapest entire homes look implausibly cheap rather than reasonable. 
-- In the neighbourhoods shown, the lowest whole-flat prices are 22 to 38 euros a night, and two listings fall at 10 and 12 euros. 
-- Before calling them errors, I’d check their minimum stay, since long-term listings may display unusual nightly prices.

-- New tool: ROW_NUMBER()
WITH 
clean AS (
    SELECT
        id,
        neighbourhood_cleansed,
        room_type,
        CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE) AS price_eur
    FROM 'data/raw/listings.csv.gz'
),
ranked AS (
    SELECT
        id,
        neighbourhood_cleansed,
        price_eur,
        ROW_NUMBER() OVER (PARTITION BY neighbourhood_cleansed ORDER BY price_eur ASC) AS price_rank
    FROM clean
    WHERE room_type='Entire home/apt' AND price_eur IS NOT NULL
)
SELECT 
    id,
    neighbourhood_cleansed,
    price_eur,
    price_rank
FROM ranked 
WHERE price_rank <= 3
ORDER BY neighbourhood_cleansed, price_rank;
