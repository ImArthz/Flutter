import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    html = resp.read().decode('shift_jis', errors='replace')

tables = re.findall(r'<table.*?>(.*?)</table>', html, re.DOTALL)
for idx, tbl in enumerate(tables):
    if "フェブラリー" in tbl or "有馬記念" in tbl or "皐月賞" in tbl or "日本ダービー" in tbl:
        print(f"Match in Table #{idx}")
        rows = re.findall(r'<tr.*?>(.*?)</tr>', tbl, re.DOTALL)
        for r in rows[:8]:
            cells = [" ".join(re.sub(r'<[^>]+>', ' ', c).split()) for c in re.findall(r'<t[dh].*?>(.*?)</t[dh]>', r, re.DOTALL)]
            print("  ", cells)
