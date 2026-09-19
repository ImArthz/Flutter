import requests
from bs4 import BeautifulSoup
import urllib.parse
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

def search_horse_netkeiba(horse_name):
    # netkeiba search URL uses euc-jp encoding for search word query param
    encoded_word = urllib.parse.quote(horse_name.encode('euc-jp'))
    search_url = f"https://db.netkeiba.com/?pid=horse_list&word={encoded_word}"
    r = requests.get(search_url, headers=headers)
    r.encoding = 'euc-jp'
    soup = BeautifulSoup(r.text, 'html.parser')
    
    # Check if redirected directly to horse page, or list page
    # Look for link to /horse/(\d+)/
    links = re.findall(r'/horse/(\d+)/', r.text)
    if links:
        horse_id = links[0]
        ped_url = f"https://db.netkeiba.com/horse/ped/{horse_id}/"
        return horse_id, ped_url
    return None, None

for h in ['ディープインパクト', 'シンボリクリスエス', 'モズアスコット']:
    hid, ped = search_horse_netkeiba(h)
    print(f"Horse '{h}' -> ID: {hid}, Pedigree URL: {ped}")
