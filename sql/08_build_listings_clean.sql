-- This query saves a clean table of 'data/raw/listings.csv.gz'

--  Note:
--      - n_bathrooms has been first generated in 01_n_bathrooms.sql from a text column bathrooms_text 
--      - price_eur has been first generated in 02_price_eur.sql 

COPY (
    SELECT 
        id,
        neighbourhood_cleansed,
        room_type,
        accommodates,
        CASE
            WHEN LOWER(bathrooms_text) LIKE '%half%' THEN 0.5
            WHEN bathrooms_text = 'No bathroom' THEN 0
            ELSE CAST(regexp_extract(bathrooms_text, '^[0-9.]+') AS DOUBLE)
        END AS n_bathrooms,
        CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE) AS price_eur,
        number_of_reviews_ltm,
        availability_365
    FROM 'data/raw/listings.csv.gz'
)
TO 'data/clean/listings_clean.parquet' (FORMAT PARQUET);

-- Check the clean data 

DESCRIBE 
SELECT *
FROM 'data/clean/listings_clean.parquet';

SELECT COUNT(*) AS n_rows, COUNT(price_eur) AS n_price, COUNT(n_bathrooms) AS n_bath
FROM 'data/clean/listings_clean.parquet';
