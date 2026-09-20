import urllib.request
import re

url = 'https://github.com/ImArthz/Flutter/actions/runs/35477730886/job/105989781014'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        html = response.read().decode('utf-8')
        
    # We want to find the raw log URL which is often in the HTML or we can just extract the error strings
    errors = re.findall(r'(?i)error:.*', html)
    for e in set(errors):
        print(e)
except Exception as ex:
    print(ex)
