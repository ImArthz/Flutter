import requests
from bs4 import BeautifulSoup
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
url = "https://www.jbis.or.jp/horse/0000742976/pedigree/"
r = requests.get(url, headers=headers)
r.encoding = 'utf-8'
print("Length:", len(r.text))
soup = BeautifulSoup(r.text, 'html.parser')
print("Title:", soup.title.string if soup.title else None)
tables = soup.find_all('table')
print(f"Total tables: {len(tables)}")
for i, t in enumerate(tables):
    print(f"Table {i} class: {t.get('class')}")
    # print first few cells
    cells = [td.get_text(strip=True) for td in t.find_all(['td', 'th'])[:5]]
    print("  Cells:", cells)
