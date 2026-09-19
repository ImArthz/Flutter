import urllib.request
import re
import sys
from bs4 import BeautifulSoup

sys.stdout.reconfigure(encoding='utf-8')

for y in [2002, 2008, 2014, 2020]:
    url = f"https://www.jra.go.jp/datafile/seiseki/replay/{y}/g1.html"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
    with urllib.request.urlopen(req) as resp:
        raw = resp.read()
    # test cp932
    html = raw.decode("cp932", errors="replace")
    soup = BeautifulSoup(html, "html.parser")
    rows = []
    for tr in soup.find_all("tr"):
        tds = [td.get_text(strip=True) for td in tr.find_all(["td", "th"])]
        links = [a["href"] for a in tr.find_all("a", href=True) if "result" in a["href"]]
        if links:
            rows.append((tds, links))
    print(f"Year {y}: Found {len(rows)} G1 races with result links.")
    if rows:
        print("  Sample row 0:", rows[0])
