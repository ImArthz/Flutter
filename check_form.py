import requests
from bs4 import BeautifulSoup
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

r = requests.get("https://db.netkeiba.com/", headers={'User-Agent': 'Mozilla/5.0'})
r.encoding = 'euc-jp'
soup = BeautifulSoup(r.text, 'html.parser')
forms = soup.find_all('form')
print(f"Found {len(forms)} forms on home page:")
for f in forms:
    print("Action:", f.get('action'), "Method:", f.get('method'))
    inputs = [(i.get('name'), i.get('value'), i.get('type')) for i in f.find_all('input')]
    print("  Inputs:", inputs)
