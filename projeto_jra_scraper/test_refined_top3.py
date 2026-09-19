import requests
from bs4 import BeautifulSoup
import re
import sys

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HTTP_HEADERS = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

def extract_race_top3(result_url):
    r = requests.get(result_url, headers=HTTP_HEADERS, timeout=15)
    r.encoding = r.apparent_encoding or 'shift_jis'
    soup = BeautifulSoup(r.text, 'html.parser')

    target_table = None
    target_headers = None

    for tbl in soup.find_all('table'):
        rows = tbl.find_all('tr')
        if not rows:
            continue
        for row in rows[:3]:
            col_heads = [re.sub(r'\s+', '', cell.get_text(strip=True)) for cell in row.find_all(['th', 'td'])]
            if any('着順' in h for h in col_heads) and any('馬名' in h for h in col_heads):
                target_table = tbl
                target_headers = col_heads
                break
        if target_table:
            break

    if not target_table:
        return []

    def find_idx(keywords):
        for i, h in enumerate(target_headers):
            if any(k in h for k in keywords):
                return i
        return -1

    idx_pos = find_idx(['着順', '着'])
    idx_name = find_idx(['馬名'])
    idx_jockey = find_idx(['騎手'])
    idx_time = find_idx(['タイム'])
    idx_weight = find_idx(['負担重量', '斤量'])
    idx_sex = find_idx(['性齢', '性'])

    entries = []
    seen_positions = set()

    for tr in target_table.find_all('tr'):
        cells = [c.get_text(strip=True) for c in tr.find_all(['td', 'th'])]
        if len(cells) <= max(idx_pos, idx_name) or idx_pos == -1 or idx_name == -1:
            continue

        pos_str = cells[idx_pos].strip()
        if pos_str in ['1', '2', '3'] and pos_str not in seen_positions:
            seen_positions.add(pos_str)
            pos = int(pos_str)
            raw_name = cells[idx_name]
            horse_name = re.sub(r'[\(（][^()（）]+[\)）]', '', raw_name).strip()

            jockey = cells[idx_jockey] if idx_jockey != -1 and len(cells) > idx_jockey else ""
            finish_time = cells[idx_time] if idx_time != -1 and len(cells) > idx_time else ""
            
            weight = 0.0
            if idx_weight != -1 and len(cells) > idx_weight:
                wm = re.search(r'(\d+\.?\d*)', cells[idx_weight])
                if wm:
                    weight = float(wm.group(1))

            sex = ""
            if idx_sex != -1 and len(cells) > idx_sex:
                s_str = cells[idx_sex]
                if '牡' in s_str: sex = '牡'
                elif '牝' in s_str: sex = '牝'
                elif 'セ' in s_str: sex = 'セン'

            entries.append({
                'position': pos,
                'horse_name': horse_name,
                'jockey': jockey,
                'finish_time': finish_time,
                'weight': weight,
                'sex': sex
            })

    return sorted(entries, key=lambda x: x['position'])

# Test
res = extract_race_top3('https://www.jra.go.jp/datafile/seiseki/g1/derby/result/derby2005.html')
for e in res:
    print(e)
