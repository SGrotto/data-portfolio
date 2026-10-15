-- This query reads the Paris Airbnb listings dataset and prepares summary statistics of the price in two steps: (i) it converts prices into a number and (ii) it calculates statistics.

------------------------------------
-- Converting prices to a number. -- 
------------------------------------

--  1. First check: currency. Prices contain '$', which is not expected for listings in Paris. However, the information in row 49 of the Data Dictionary of the Paris listing dataset website (https://docs.google.com/spreadsheets/d/1iWCNJcSutYqpULSQHlNyGInUvHg2BoUGoNRIGa6Szc4/edit?gid=1322284596#gid=1322284596) indicates the price is in local currency and the $ is to be ignored.
--  2. For the price to be converted to a number, only commas between integers and decimals must remain: we then remove commas included in integers (",") and the US dollars symbol.
--  3. We use CAST for the conversion - in order to assess its effectiveness, we compare the total number of rows of non-missing prices with that of the converted prices: the numbers are identical, which validates the conversion and guarantees that no non-missing price became NULL.


------------------------
-- Summary statistics --
------------------------

-- 1.  Table including min, max, average, and median
        WITH clean AS (
            SELECT
                id,
                room_type,
                accommodates,
                CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE) AS price_eur
            FROM 'data/raw/listings.csv.gz'
        )
        SELECT 
            COUNT(price_eur) AS n_non_missing_prices,
            MIN(price_eur) AS price_min,
            MAX(price_eur) AS price_max,
            ROUND(AVG(price_eur)) AS price_average,
            MEDIAN(price_eur) AS price_median
        FROM clean;

-- 2. Top 10 listings highest prices 
        WITH clean AS (
            SELECT
                id,
                room_type,
                accommodates,
                CAST(REPLACE(REPLACE(price, ',', ''), '$', '') AS DOUBLE)  AS price_eur
            FROM 'data/raw/listings.csv.gz'
        )
        SELECT 
            id, room_type, accommodates, price_eur
        FROM clean
        ORDER BY price_eur DESC
        LIMIT 10;
    
--  Preliminary observations : 
    --  (i) the average (337€) is relatively high compare to the median (218€) because some listings have very high values.
    --  (ii) the minimum price is relatively low (about 10€ a night).
    --  (iii) however, further investigation is needed before calling these errors: low price can be shared rooms in hostels, and high prices luxury and large apartments.

