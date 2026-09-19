import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
text = raw.decode("cp932", errors="replace")

pos = text.find("レース名")
print("Position of レース名:", pos)
if pos != -1:
    print("Context around it:")
    print(text[pos-100:pos+1500])
