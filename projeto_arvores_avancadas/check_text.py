import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()

# Try cp932
text = raw.decode("cp932", errors="replace")
print("Length of text:", len(text))
for line in text.splitlines():
    if "レース名" in line or "優勝馬" in line or "メイショウボーラー" in line or "ディープインパクト" in line:
        print("Found line:", line[:100])
