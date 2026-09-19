import requests
from bs4 import BeautifulSoup
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

def parse_jbis_pedigree(horse_id):
    url = f"https://www.jbis.or.jp/horse/{horse_id}/pedigree/"
    r = requests.get(url, headers=headers)
    r.encoding = 'utf-8'
    soup = BeautifulSoup(r.text, 'html.parser')
    
    inner = soup.find('div', class_='data-3__inner')
    if not inner:
        return None
        
    sire_div = inner.find('div', class_='data-3__male', recursive=False)
    dam_div = inner.find('div', class_='data-3__female', recursive=False)
    
    def get_horse_info(container):
        if not container:
            return None, None
        # the main horse link in this container
        # usually the first /horse/\d+/ link that has text
        for a in container.find_all('a', href=re.compile(r'/horse/\d+/?$')):
            name = a.get_text(strip=True)
            m = re.search(r'/horse/(\d+)/?$', a['href'])
            if m and name and 'English' not in name:
                return m.group(1), name
        return None, None

    sire_id, sire_name = get_horse_info(sire_div)
    dam_id, dam_name = get_horse_info(dam_div)
    
    # Grandsires:
    sire_sire_div = sire_div.find('div', class_='data-3__male') if sire_div else None
    grandsire_id, grandsire_name = get_horse_info(sire_sire_div)
    
    dam_sire_div = dam_div.find('div', class_='data-3__male') if dam_div else None
    dam_sire_id, dam_sire_name = get_horse_info(dam_sire_div)
    
    return {
        'sire_id': sire_id, 'sire_name': sire_name,
        'dam_id': dam_id, 'dam_name': dam_name,
        'grandsire_id': grandsire_id, 'grandsire_name': grandsire_name,
        'dam_sire_id': dam_sire_id, 'dam_sire_name': dam_sire_name
    }

# Test Deep Impact (0000742976)
info = parse_jbis_pedigree('0000742976')
print("Deep Impact pedigree:")
for k, v in info.items():
    print(f"  {k}: {v}")
