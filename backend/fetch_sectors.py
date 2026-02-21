import requests
r = requests.get('http://127.0.0.1:5000/api/sectors', timeout=120)
print('status', r.status_code)
try:
    j = r.json()
    print('keys:', list(j.keys())[:10])
    print('total_count:', j.get('total_count'))
    print('sector_count:', j.get('sector_count'))
    # Print first 5 sector names
    sectors = j.get('sectors', {})
    print('sample sectors:', list(sectors.keys())[:10])
except Exception as e:
    print('error parsing json:', e)
    print(r.text[:2000])
