import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://db.netkeiba.com/horse/ped/2002100816/"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
text = raw.decode("euc-jp", errors="replace")

# Let's search for blood_table
match = re.search(r'<table[^>]*class="blood_table"[^>]*>(.*?)</table>', text, re.DOTALL)
if match:
    tbl = match.group(1)
    links = re.findall(r'<a href="([^"]+)"[^>]*>(.*?)</a>', tbl)
    print(f"Found {len(links)} links in blood_table:")
    for link, name in links[:10]:
        print("  ", link, "-->", name)
else:
    print("blood_table not found, checking all tables")
    tables = re.findall(r'<table[^>]*>(.*?)</table>', text, re.DOTALL)
    print("Found tables:", len(tables))
