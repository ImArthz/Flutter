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
for i, t in enumerate(tables):
    links = re.findall(r'<a href="([^"]+)"[^>]*>(.*?)</a>', t)
    print(f"Table {i} has {len(links)} links. First 3:")
    for l, n in links[:3]:
        print(f"   {l} -> {n.strip()}")
