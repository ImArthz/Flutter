import requests
from bs4 import BeautifulSoup
import sys

sys.stdout.reconfigure(encoding='utf-8')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
url = "https://www.jbis.or.jp/horse/0000742976/pedigree/"
r = requests.get(url, headers=headers)
r.encoding = 'utf-8'
soup = BeautifulSoup(r.text, 'html.parser')

inner = soup.find('div', class_='data-3__inner')
print("Inner classes and children:")
for child in inner.children:
    if child.name:
        print(f"Child: tag={child.name}, class={child.get('class')}")
        # print first 200 chars
        print("   Snippet:", child.get_text(strip=True)[:100])
