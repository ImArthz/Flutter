import requests
from bs4 import BeautifulSoup
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0'}

test_urls = [
    ("2002 Derby", "https://www.jra.go.jp/datafile/seiseki/g1/derby/result/derby2002.html"),
    ("2010 Derby", "https://www.jra.go.jp/datafile/seiseki/g1/derby/result/derby2010.html"),
    ("2020 Feb", "https://www.jra.go.jp/datafile/seiseki/g1/feb/result/feb2020.html")
]

for name, url in test_urls:
    r = requests.get(url, headers=headers)
    r.encoding = r.apparent_encoding
    soup = BeautifulSoup(r.text, 'html.parser')
    top3 = []
    for tr in soup.find_all('tr'):
        tds = [td.get_text(strip=True) for td in tr.find_all(['td', 'th'])]
        if tds and tds[0] in ['1', '2', '3']:
            # Find horse name
            # Let's inspect all cells in the row
            top3.append(tds)
    print(f"=== {name} ===")
    for row in top3[:3]:
        print("  ", row[:6])
