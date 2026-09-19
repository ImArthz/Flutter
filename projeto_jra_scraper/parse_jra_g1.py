import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
text = raw.decode("cp932", errors="replace")

# Let's find the main table that lists the races
tables = re.findall(r'<table[^>]*>(.*?)</table>', text, re.DOTALL)
for idx, tbl in enumerate(tables):
    if "レース名" in tbl:
        print(f"--- Table #{idx} ---")
        rows = re.findall(r'<tr[^>]*>(.*?)</tr>', tbl, re.DOTALL)
        for r in rows:
            cells = [" ".join(re.sub(r'<[^>]+>', ' ', c).split()) for c in re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>', r, re.DOTALL)]
            links = re.findall(r'href="([^"]+)"', r)
            if len(cells) >= 3:
                print(cells, links)
