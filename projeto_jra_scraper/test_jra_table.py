import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    html = resp.read().decode('shift_jis', errors='replace')

# Print snippet
print("HTML length:", len(html))
# Let's search for table or race names
matches = re.findall(r'<table.*?>(.*?)</table>', html, re.DOTALL)
print(f"Tables found: {len(matches)}")
if matches:
    rows = re.findall(r'<tr.*?>(.*?)</tr>', matches[0], re.DOTALL)
    print(f"Rows in first table: {len(rows)}")
    for r in rows[:6]:
        cells = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[dh].*?>(.*?)</t[dh]>', r, re.DOTALL)]
        print("ROW:", cells)
