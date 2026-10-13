-- This query reads the Paris Airbnb listings dataset and extracts the number of bathrooms recorded in each distinct value of the bathrooms_text column.

-- The following cleaning rules are applied :
--  - Values of bathrooms_text containing "half" are assigned a number of bathrooms of 0.5: a half-bath is a room with a toilet and sink but no shower or bath, conventionally counted as 0.5.
--  - Rows recording "No bathroom" are assigned 0 bathrooms.
--  - Rows recording NULL are unmodified and still display NULL. These have no information on the number of bathrooms reported, so no assumption about such number can be made, which is why we leave them empty.

-- Please note the following observations:
--  - Information on whether baths are private, shared, or unspecified is not reported in the output column n_bathrooms, but are recorded in bathrooms_text.
--  - A few listings report 10 or more bathrooms (up to 42); likely hostels or hotels, to be checked.

-- SQL QUERY 

SELECT
    bathrooms_text,
    CASE
        WHEN LOWER(bathrooms_text) LIKE '%half%' THEN 0.5
        WHEN bathrooms_text = 'No bathroom' THEN 0
        ELSE CAST(regexp_extract(bathrooms_text, '^[0-9.]+') AS DOUBLE)
    END AS n_bathrooms,
    COUNT(*) AS n
FROM 'data/raw/listings.csv.gz'
GROUP BY ALL
ORDER BY n DESC;