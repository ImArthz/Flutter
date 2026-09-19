import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://db.netkeiba.com/horse/ped/2002100816/"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
text = raw.decode("euc-jp", errors="replace")

tables = re.findall(r'<table[^>]*>(.*?)</table>', text, re.DOTALL)
t0 = tables[0]
# Each td in the pedigree table has the ancestor name and link
tds = re.findall(r'<td[^>]*>(.*?)</td>', t0, re.DOTALL)
print(f"Total cells in pedigree table: {len(tds)}")
for idx, td in enumerate(tds[:15]):
    # find horse page link
    links = re.findall(r'<a href="https://db\.netkeiba\.com/horse/([^/]+)/"[^>]*>(.*?)</a>', td)
    clean_text = " ".join(re.sub(r'<[^>]+>', ' ', td).split())
    print(f"Cell {idx}: text='{clean_text}' | links={links}")
