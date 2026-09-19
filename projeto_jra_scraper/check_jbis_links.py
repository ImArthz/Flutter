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

links = soup.find_all('a', href=re.compile(r'/horse/\d+/'))
print(f"Found {len(links)} horse links on JBIS pedigree page:")
for a in links[:20]:
    print("  ", a['href'], "->", a.get_text(strip=True))
