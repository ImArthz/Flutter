import urllib.request
import json
import re

# Get the latest run
url_runs = 'https://api.github.com/repos/ImArthz/Flutter/actions/runs'
req = urllib.request.Request(url_runs)
with urllib.request.urlopen(req) as response:
    runs = json.loads(response.read().decode())

latest_run_id = runs['workflow_runs'][0]['id']

# Get jobs
url_jobs = f'https://api.github.com/repos/ImArthz/Flutter/actions/runs/{latest_run_id}/jobs'
req2 = urllib.request.Request(url_jobs)
with urllib.request.urlopen(req2) as response:
    jobs = json.loads(response.read().decode())

job_id = jobs['jobs'][0]['id']
job_html_url = jobs['jobs'][0]['html_url']

print(f"Job URL: {job_html_url}")
