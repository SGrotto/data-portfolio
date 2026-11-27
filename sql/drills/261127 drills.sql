
SELECT 
    neighbourhood_cleansed,
    COUNT(*) AS n_homes,
    ROUND(100*AVG(CASE WHEN availability_365 = 0 THEN 1 ELSE 0 END),1) AS pct_dormant,
    MEDIAN(availability_365) AS median_availability
FROM 'data/clean/listings_clean.parquet'
WHERE room_type='Entire home/apt'
GROUP BY neighbourhood_cleansed
HAVING COUNT(*)>=2000
ORDER BY AVG(CASE WHEN availability_365 = 0 THEN 1 ELSE 0 END) DESC
LIMIT 5;
-- 6min30

Answer: not based on this evidence
Evidence: First, the figure does not show abandoned listing but dormant, second it is incomplete and does not include all eartern Paris neighbourhood, despite most of them showing about 40% of formant listings.
Limit: one should look at the percentage on all neighbourhood and compute the sum of those in eastern Paris 