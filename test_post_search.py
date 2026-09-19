import requests
from bs4 import BeautifulSoup
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

def search_horse(name):
    url = "https://db.netkeiba.com/horse/search_all.html"
    # Word needs to be sent encoded in euc-jp
    # requests allows bytes payload or form-encoded
    payload = {'word': name.encode('euc-jp')}
    r = requests.post(url, data=payload, headers=headers)
    r.encoding = 'euc-jp'
    # Check if redirected directly or list
    print(f"Searched '{name}', final URL: {r.url}, status: {r.status_code}")
    # Find links to /horse/(\d+)/
    match = re.search(r'/horse/(\d+)/', r.text)
    if match:
        hid = match.group(1)
        print(f"  Found horse_id: {hid} -> https://db.netkeiba.com/horse/ped/{hid}/")
        return hid
    return None

search_horse("ディープインパクト")
search_horse("シンボリクリスエス")
search_horse("モズアスコット")
