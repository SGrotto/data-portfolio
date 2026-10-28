-- This file analyses Airbnb activity in Paris
-- Note: all results reveal a survivorship bias, i.e. all listings we see in this dataset are those still on the website (whether
-- they are active or not), but not those hosts deleted. So every past year is undercounted, and the further back, the worse.

-- Question: how has Airbnb activity in Paris changed over time? Reviews are our proxy for stays, as before.
-- Write a query on data/raw/reviews.csv that returns the number of reviews per year, sorted by year.
SELECT
    year(date) AS review_year,
    COUNT(*) AS n_reviews
FROM 'data/raw/reviews.csv'
GROUP BY year(date)
ORDER BY year(date) ASC;
-- Reviews of current Paris listings grew strongly, apart from a collapse during Covid. 
-- They fell by 64% in 2020, then reached 492,000 in 2025, over three times the 2019 level. 
-- But the file only holds reviews of listings still online today, so earlier years are undercounted, and 2026 stops in late September

-- Question: is Airbnb activity in 2026 really lower than in 2025, or is it only the missing months?
-- Write a query that returns the number of reviews from January to August, for 2025 and for 2026 only, one row per year
SELECT
    year(date) AS review_year,
    COUNT(*) AS n_review
FROM 'data/raw/reviews.csv'
WHERE (year(date)=2025 AND month(date)<=8) OR (year(date)=2026 AND month(date)<=8)
GROUP BY year(date)
ORDER BY year(date) ASC;
-- 

-- Question: when in the year is Paris busiest on Airbnb?
-- Write a query that counts reviews per month (1 to 12) for 2025 only, the latest complete year, sorted by month.
SELECT
    month(date) AS review_month_2025,
    COUNT(*) AS n_review
FROM 'data/raw/reviews.csv'
WHERE year(date)=2025
GROUP BY month(date)
ORDER BY month(date) ASC;
-- Paris is busiest in late spring and autumn, not in summer. 
-- Reviews peak in June (57,800) and October (48,700), while August (37,600) is closer to winter levels. 
-- Since guests review a week or two after their stay, each month partly reflects the previous month’s activity.