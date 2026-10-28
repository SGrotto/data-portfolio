-- This file analyses the seasonality of Airbnb activity in Paris

-- Question: is the August dip a pattern every year, or a 2025 accident?
SELECT
    month(date) AS review_month,
    SUM(CASE WHEN year(date) = 2023 THEN 1 ELSE 0 END) AS n_2023,
    SUM(CASE WHEN year(date) = 2024 THEN 1 ELSE 0 END) AS n_2024,
    SUM(CASE WHEN year(date) = 2025 THEN 1 ELSE 0 END) AS n_2025
FROM 'data/raw/reviews.csv'
WHERE year(date) IN (2023, 2024, 2025)
GROUP BY month(date)
ORDER BY month(date);
-- Every year, activity drops in summer after a June peak and recovers in October, but 2024 breaks the pattern. 
-- In 2024, July fell below its 2023 level while August rose well above it, which matches the timing of the Paris Olympics. 
-- Survivorship distorts comparisons across years more than the pattern within a year, so the seasonality is the more reliable finding


-- Question: each year has more reviews than the last, which makes the columns hard to compare. What share of each year’s reviews falls in each month?
WITH total_by_year AS (
SELECT 
    year(date) as review_year,
    month(date) AS review_month,
    COUNT(*) OVER (PARTITION BY year(date)) AS total_year
FROM 'data/raw/reviews.csv'
WHERE year(date) IN (2023, 2024, 2025)
)
SELECT 
    review_year,
    review_month,
    COUNT(*) AS n,
    ROUND(COUNT(*) / MAX(total_year),3) AS monthly_share
FROM total_by_year
GROUP BY review_year, review_month
ORDER BY review_year, review_month;
-- Yes: July’s share drops to 7.7% in 2024, against about 10% and 9% in the other years, while August rises to 9.3%, against about 8%

