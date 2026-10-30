# Cress in Nottingham dashboard

A static page (`index.html`) that reads `data.json`. Hosted on Netlify, deployed from this repo: every push to `main` republishes the site.

## How the figures refresh

A scheduled Claude task runs on Jake's Mac every weekday morning:

1. Runs each query in `sql/` against the Cress production database (the `Cress_db_production` connector on the Mac).
2. Saves each result, exactly as returned (CSV with a header row), to `raw/<name>.csv`.
3. Runs `python3 scripts/build_data.py`, which rebuilds `data.json` and stops with an error if the numbers don't add up.
4. Commits and pushes if `data.json` changed. Netlify picks up the push.

The Mac needs to be awake with the Claude desktop app open at refresh time. If a run is missed, the page keeps showing the last good figures and its "Updated" stamp says when.

## What the numbers mean

- Nottingham City Council schools are store group 166. Paid, uncancelled orders since 1 July 2026, test items excluded.
- Saving per preloved item: new price from `swapshop.tblProductPricingMatrix` for the school's phase, branded or plain, times quantity, less what was paid, never below zero. Blazers and coats (product 7020) are not in the price list yet, so they count at £30 new.
- Carbon, water and waste are the values recorded on each sold item.
