import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://db.netkeiba.com/horse/ped/2002100816/"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
try:
    with urllib.request.urlopen(req) as resp:
        raw = resp.read()
    text = raw.decode("euc-jp", errors="replace")
    print("Pedigree title:", re.findall(r'<title>(.*?)</title>', text))
    # Pedigree table is typically a 5-generation table (table class blood_table)
    # Let's find horse links inside the pedigree table
    horses = re.findall(r'<a href="/horse/ped/(\w+)/"[^>]*>(.*?)</a>', text)
    print(f"Total pedigree links: {len(horses)}")
    for hid, hname in horses[:10]:
        print(f"  ID: {hid} -> Name: {hname}")
except Exception as e:
    print("Error:", e)
