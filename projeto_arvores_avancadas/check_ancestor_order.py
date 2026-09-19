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

inner = soup.find('div', class_='data-3__inner')
items = inner.find_all('div', class_='data-3__items', recursive=False)
sire_block = items[0]
dam_block = items[1]

def get_names_in_order(block):
    res = []
    for a in block.find_all('a', href=re.compile(r'/horse/\d+/$')):
        t = a.get_text(strip=True)
        if t and t not in ['血統', '競走', '種', '繁殖', 'English']:
            m = re.search(r'/horse/(\d+)/$', a['href'])
            res.append((m.group(1), t))
    return res

sire_ancestors = get_names_in_order(sire_block)
dam_ancestors = get_names_in_order(dam_block)

print("Sire block top ancestors:")
for hid, name in sire_ancestors[:8]:
    print("  ", hid, "->", name)

print("\nDam block top ancestors:")
for hid, name in dam_ancestors[:8]:
    print("  ", hid, "->", name)
