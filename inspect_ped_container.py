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

# Find element containing Sunday Silence
a_sire = soup.find('a', string=re.compile('サンデーサイレンス'))
if a_sire:
    parent = a_sire.parent
    for i in range(5):
        print(f"Parent {i}: tag={parent.name}, class={parent.get('class')}, id={parent.get('id')}")
        parent = parent.parent
