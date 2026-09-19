import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
text = raw.decode("cp932", errors="replace")

pos = 0
while True:
    pos = text.find("レース名", pos + 1)
    if pos == -1:
        break
    print(f"Occurrence at {pos}:")
    print(text[pos:pos+300])
    print("="*40)
