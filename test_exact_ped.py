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

def extract_horse(container):
    # Find the title/horse link
    for a in container.find_all('a', href=re.compile(r'/horse/\d+/$')):
        name = a.get_text(strip=True)
        if name and name not in ['血統', '競走', '種', '繁殖', 'English']:
            m = re.search(r'/horse/(\d+)/$', a['href'])
            return m.group(1), name
    return None, None

print("Sire (Pai):", extract_horse(sire_block))
print("Dam (Mãe):", extract_horse(dam_block))

# Inside sire_block, find child items for grandsire
sire_sub_males = sire_block.find_all('div', class_='data-3__male')
print("Sire's Sire (Avô Paterno):", extract_horse(sire_sub_males[0]) if sire_sub_males else None)

dam_sub_males = dam_block.find_all('div', class_='data-3__male')
print("Dam's Sire (Avô Materno / Damsire):", extract_horse(dam_sub_males[0]) if dam_sub_males else None)
