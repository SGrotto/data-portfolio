-- This query reads the Paris Airbnb listings dataset and extracts the number of bathrooms recorded in each distinct value of the bathrooms_text column.
-- The following cleaning rules are applied :
--  - Values of bathrooms_text containing "half" have been assigned a number of bathroom of 0.5 (self-explanatory)
--  - Rows recording "No bathroom" have been assigned 0 bathroom.
--  - Rows recording NULL have been unmodified and still display NULL. These have no information on the number of bathrooms reported, so no assumption about such number can be made, which is why we leave them empty.
-- Please note the following observations:
--  - Information on whether baths are private, shared, or unspecified is not reported in the output column n_bathrooms_str, but are recorded in bathrooms_text.
--  - The output column contains outliers (> 30 baths). Checks on them must be performed.

-- SQL QUERY 

SELECT
    bathrooms_text,
    CASE
        WHEN LOWER(bathrooms_text) LIKE '%half%' THEN 0.5
        WHEN bathrooms_text = 'No bathroom' THEN 0
        ELSE CAST(regexp_extract(bathrooms_text, '^[0-9.]+') AS DOUBLE)
    END AS n_bathrooms,
    COUNT(*) AS n,
FROM 'data/raw/listings.csv.gz'
GROUP BY ALL
ORDER BY n DESC;