"""Turn the three query results in raw/ into data.json for the dashboard.

Usage: python3 scripts/build_data.py
Each raw/<name>.csv is the CSV text the Cress_db_production query_sql tool returns
for sql/<name>.sql (header row first). Exits non-zero if anything looks wrong,
so a bad refresh never overwrites good data.
"""
import csv, json, sys, datetime, pathlib

root = pathlib.Path(__file__).resolve().parent.parent

def rows(name):
    text = (root / "raw" / f"{name}.csv").read_text(encoding="utf-8").strip()
    return list(csv.DictReader(text.splitlines()))

def num(v):
    f = float(v)
    return int(f) if f.is_integer() else f

h = rows("headline")
w = rows("weekly")
s = rows("schools")
if len(h) != 1 or not w or not s:
    sys.exit("Unexpected query results: check raw/*.csv")

head = {k: (v if k in ("firstSale", "lastSale") else num(v)) for k, v in h[0].items()}
weekly = [{"weekStart": r["weekStart"], "families": num(r["families"]), "items": num(r["items"]), "saved": num(r["saved"])} for r in w]
schools = [{"school": r["school"], "families": num(r["families"]), "items": num(r["items"]), "freeItems": num(r["freeItems"]), "saved": num(r["saved"])} for r in s]

total_w = round(sum(r["saved"] for r in weekly), 2)
if abs(total_w - head["saved"]) > 0.05:
    sys.exit(f"Weekly savings {total_w} do not add up to headline {head['saved']}")

out = {
    "updatedAt": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "headline": head,
    "weekly": weekly,
    "schools": schools,
}
(root / "data.json").write_text(json.dumps(out, indent=1, ensure_ascii=False), encoding="utf-8")
print(f"data.json written: £{head['saved']:,} saved, {head['families']} families, last sale {head['lastSale']}")
