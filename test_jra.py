import urllib.request
import re
import sys

# Set stdout to UTF-8
sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/replay/2005/g1.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
try:
    with urllib.request.urlopen(req) as resp:
        html = resp.read().decode('shift_jis', errors='replace')
        
    # Find links
    links = re.findall(r'href=["\']([^"\']+)["\']', html)
    g1_links = [l for l in links if '05' in l or 'replay' in l or 'g1' in l]
    print(f"Total links: {len(links)}, G1 candidate links: {len(g1_links)}")
    for l in g1_links[:10]:
        print(" -", l)
except Exception as e:
    print("Error:", e)
