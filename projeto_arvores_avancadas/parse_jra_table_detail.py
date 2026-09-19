import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
text = raw.decode("cp932", errors="replace")

pos = text.find('WIDTH="605"')
sub = text[pos:]
end_tbl = sub.find('</TABLE>')
tbl_html = sub[:end_tbl]

rows = re.findall(r'<TR[^>]*>(.*?)</TR>', tbl_html, re.DOTALL | re.IGNORECASE)
print(f"Total rows in G1 table: {len(rows)}")
for r in rows:
    cells = [" ".join(re.sub(r'<[^>]+>', ' ', c).split()) for c in re.findall(r'<T[DH][^>]*>(.*?)</T[DH]>', r, re.DOTALL | re.IGNORECASE)]
    links = re.findall(r'href="([^"]+)"', r, re.IGNORECASE)
    print("Row:", cells, "Links:", links)
