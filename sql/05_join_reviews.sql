-- This query joins the Paris Airbnb listings dataset with the summary review data 

-- Task: joins the two datasets

-- Comments --
--------------

--  - Granularity: what does each row represent - the listings data records one row per listing (id), 
--                 whereas the review data records one row per listing (listing_id) and publication date (day) of a review for that listing. 
--                 That means it is necessary to transform the review data at the level of a listing: we do this in a CTE,
--                 keeping the information on the date of the first and last reviews, as well as the total number of reviews.
--                 In numbers: the listings data records 77,149 rows and listing IDs
--                             the review data records 2,503,875 rows but 61,753 distincts listing IDs
--  - Join: 
--      1. The left join keeps all rows from the "left" dataset, here the listing data, which results in a post-join dataset of 77,149 rows. 
--         All 61,753 listings from the review file are merged to the listings data, which means 15,396 listings in the left data have no reviews, i.e. ca. 20%.
--         20% is plausible, but these certainly represent new or inactive listings. To be checked.
--      2. The inner join keeps rows found in both datasets only, resulting in a post-join dataset of 61,753 rows.
--  - Others: it is worth mentioning that the Paris listings data from Inside Airbnb was collected, according to the snapshot date in the website,
--            on 16 September 2026. However, the last review date found in the review data is 22 September 2026, i.e. 6 days later. The most likely explanation 
--            is that the two files weren’t collected at exactly the same moment: the reviews file was scraped a few days after the date on the label.

-- Query --
-----------

--  1. LEFT JOIN 
        WITH reviews_per_listing AS (
        SELECT
            listing_id,
            COUNT(*) AS n_reviews,
            MIN(date) AS date_first_review,
            MAX(date) AS date_last_review
        FROM 'data/raw/reviews.csv'
        GROUP BY listing_id
        )
        SELECT
            COUNT(*) AS n_left_join,
            COUNT(l.id) - COUNT(r.listing_id) AS n_missing_reviews
        FROM 'data/raw/listings.csv.gz' AS l
        LEFT JOIN reviews_per_listing AS r
            ON l.id = r.listing_id;

--  2. INNER JOIN 
        WITH reviews_per_listing AS (
            SELECT
                listing_id,
                COUNT(*) AS n_reviews,
                MIN(date) AS date_first_review,
                MAX(date) AS date_last_review
            FROM 'data/raw/reviews.csv'
            GROUP BY listing_id
        )
        SELECT
            COUNT(*) AS n_inner_join,
            COUNT(l.id) - COUNT(r.listing_id) AS n_missing_reviews
        FROM 'data/raw/listings.csv.gz' AS l
        INNER JOIN reviews_per_listing AS r
            ON l.id = r.listing_id;
