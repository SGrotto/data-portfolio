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

## Tools

DuckDB (SQL), pandas (Python), Power BI, Git and GitHub.