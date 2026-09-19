import requests
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
url = "https://db.netkeiba.com/horse/search_all.html"
payload = {'word': 'ディープインパクト'.encode('euc-jp')}
r = requests.post(url, data=payload, headers=headers)
r.encoding = 'euc-jp'
links = re.findall(r'<a href="([^"]+)"[^>]*>(.*?)</a>', r.text)
for l, t in links[15:]:
    if "horse" in l or "ディープ" in t:
        print("  MATCH:", l, "->", t)
