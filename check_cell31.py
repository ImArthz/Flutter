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
tds = re.findall(r'<td[^>]*>(.*?)</td>', tables[0], re.DOTALL)
print(f"Cell 31: {' '.join(re.sub(r'<[^>]+>', ' ', tds[31]).split())}")
