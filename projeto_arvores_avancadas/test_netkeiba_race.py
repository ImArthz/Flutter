import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

# Example 2005 Arima Kinen: 200506050809 (or search for 2005 Arima Kinen)
# Let's search netkeiba for Arima Kinen 2005 or Deep Impact Japan Cup / Derby 2005
# Netkeiba race ID format: YYYY (4) + Track (2) + Meeting (2) + Day (2) + RaceNum (2) = 12 digits
# Let's test Deep Impact's Japanese Derby 2005: 200505030410
url = "https://db.netkeiba.com/race/200505030410/"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
try:
    with urllib.request.urlopen(req) as resp:
        raw = resp.read()
    text = raw.decode("euc-jp", errors="replace")
    print("Race page title:", re.findall(r'<title>(.*?)</title>', text))
    # Extract table rows
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', text, re.DOTALL)
    print(f"Total rows: {len(rows)}")
    for r in rows[1:5]: # top horses
        cols = [re.sub(r'<[^>]+>', '', c).strip() for c in re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>', r, re.DOTALL)]
        # Also extract horse link
        horse_links = re.findall(r'/horse/(\d+)/', r)
        print("Placing:", cols[:5], "Horse ID:", horse_links)
except Exception as e:
    print("Error:", e)
