import sys
sys.path.insert(0, './backend')
from app import _scrape_news

print('Testing _scrape_news...')
res = _scrape_news('IHSG')
print(f'Total news logic: {len(res) if res else 0}')

if res:
    have_impact = 0
    for r in res[:20]:
        codes = r.get('impactCodes', [])
        print(f"[{','.join(codes)}] {r['title'][:80]}")
        if codes: have_impact += 1
    print(f"\nItems with codes in top 20: {have_impact}")
