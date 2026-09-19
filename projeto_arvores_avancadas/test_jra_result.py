import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "https://www.jra.go.jp/datafile/seiseki/g1/derby/result/derby2005.html"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
try:
    with urllib.request.urlopen(req) as resp:
        raw = resp.read()
    text = raw.decode("cp932", errors="replace")
    print("Result page length:", len(text))
    # Look for finishing order (着順)
    tables = re.findall(r'<TABLE[^>]*>(.*?)</TABLE>', text, re.DOTALL | re.IGNORECASE)
    print("Found tables:", len(tables))
    for idx, t in enumerate(tables):
        if "着順" in t or "ディープインパクト" in t:
            print(f"Match in table #{idx}")
            rows = re.findall(r'<TR[^>]*>(.*?)</TR>', t, re.DOTALL | re.IGNORECASE)
            for r in rows[:6]:
                cells = [" ".join(re.sub(r'<[^>]+>', ' ', c).split()) for c in re.findall(r'<T[DH][^>]*>(.*?)</T[DH]>', r, re.DOTALL | re.IGNORECASE)]
                print("  ", cells)
except Exception as e:
    print("Error:", e)
