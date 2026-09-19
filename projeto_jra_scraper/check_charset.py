import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    raw = resp.read()
    charset = resp.headers.get_content_charset()
    print("Charset:", charset)
    # check meta charset
    meta = re.findall(rb'<meta[^>]+charset=["]?([^"\'\s>]+)', raw, re.IGNORECASE)
    print("Meta charset:", meta)
