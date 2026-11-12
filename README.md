# data-portfolio

This repo analyses Paris Airbnb listings, using publicly available data from Inside Airbnb.
The author, Sébastien Grotto, is an economist who spent seven years cleaning, structuring and auditing large datasets for competition cases across many industries.

## Structure

- `data/raw`: raw data as downloaded (not committed)
- `data/clean`: cleaned data produced by the scripts (not committed)
- `sql`: SQL queries
- `python`: Python scripts and notebooks
- `docs`: documentation and final outputs

## Data source

- Inside Airbnb, Paris listings (`listings.csv.gz`)
- Snapshot date: 2026-09-16
- Download URL: https://data.insideairbnb.com/france/ile-de-france/paris/2026-09-16/data/listings.csv.gz
- Licence: Creative Commons Attribution 4.0 (CC BY 4.0)
- To reproduce: download the file from the URL above and place it in `data/raw/`
- Note: prices in the raw data contain the $ symbol but are actually recorded in euros (source: row 49 of Inside Airbnb Data Dictionary: https://docs.google.com/spreadsheets/d/1iWCNJcSutYqpULSQHlNyGInUvHg2BoUGoNRIGa6Szc4/edit?gid=1322284596#gid=1322284596)

## Tools

DuckDB (SQL), pandas (Python), Power BI, Git and GitHub.

## SQL analysis 

### Data preparation
- Prices converted from text to numbers; they are in euros despite the `$` sign (file 02).
- Number of bathrooms extracted from the `bathrooms_text` column (file 01).
- Cleaned data saved as `data/clean/listings_clean.parquet` (file 08).

### Key findings
- **Location drives price:** the median entire home costs 352 euros a night in Élysée, against 155 in Ménilmontant (file 04).
- **44% of listings have no price.** These are much less likely to have been reviewed in the past year (38% against 85% of priced listings), and most recently reviewed ones had no available nights at all (59% against 2%) (files 06, 09).
- **Some prices look deliberately unbookable:** a few listings cost 65 to 484 times their neighbourhood median (file 07), and 61% of listings above 1,000 euros had no review in a year, against 28% of the others (file 03).
- **Paris is busiest in June and October, not in summer.** In 2024, the Olympics shifted activity from July to August (files 10, 11).

### Caveats
- Snapshot of 16 September 2026. Reviews only cover listings still online at that date, so past activity is undercounted (survivorship bias).