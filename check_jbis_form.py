import requests
from bs4 import BeautifulSoup
import sys

sys.stdout.reconfigure(encoding='utf-8')

r = requests.get("https://www.jbis.or.jp/", headers={'User-Agent': 'Mozilla/5.0'})
r.encoding = 'utf-8'
soup = BeautifulSoup(r.text, 'html.parser')
forms = soup.find_all('form')
print(f"JBIS Forms: {len(forms)}")
for f in forms:
    print("Action:", f.get('action'), "Method:", f.get('method'))
    for i in f.find_all(['input', 'select']):
        print("  Input:", i.get('name'), i.get('value'), i.get('type'))
