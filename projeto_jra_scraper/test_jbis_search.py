import requests
from bs4 import BeautifulSoup
import urllib.parse
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

for horse in ['ディープインパクト', 'シンボリクリスエス', 'モズアスコット']:
    # GET query to /horse/result/
    url = f"https://www.jbis.or.jp/horse/result/?sid=horse&keyword={urllib.parse.quote(horse)}&match=exact"
    r = requests.get(url, headers=headers)
    r.encoding = 'utf-8'
    # Look for /horse/(\d+)/
    matches = re.findall(r'/horse/(\d+)/', r.text)
    print(f"JBIS Horse '{horse}' status {r.status_code}: matches={matches[:3]}")
    if matches:
        ped_url = f"https://www.jbis.or.jp/horse/{matches[0]}/pedigree/"
        print(f"  Pedigree URL: {ped_url}")
