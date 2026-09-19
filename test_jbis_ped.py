import requests
from bs4 import BeautifulSoup
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
url = "https://www.jbis.or.jp/horse/0000742976/pedigree/"
r = requests.get(url, headers=headers)
r.encoding = 'utf-8'
soup = BeautifulSoup(r.text, 'html.parser')

# Look for js-pedigree or table
tbl = soup.find('table', class_=re.compile(r'tbl-data-04|pedigree', re.I)) or soup.find('div', id='js-pedigree')
if not tbl:
    tbl = soup.find('table')

print("Found table/div:", tbl.name if tbl else None)
# Extract sire and dam
# In JBIS, pedigree table has links to /horse/<id>/
horse_links = []
for a in tbl.find_all('a', href=True):
    m = re.search(r'/horse/(\d+)/', a['href'])
    if m:
        horse_links.append((m.group(1), a.get_text(strip=True)))

print(f"Total horse links in JBIS pedigree: {len(horse_links)}")
for hid, name in horse_links[:10]:
    print(f"  {hid} -> {name}")
