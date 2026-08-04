"""Read-only: what is on every track right now, and what versionCodes exist."""
import os

from google.oauth2 import service_account
from googleapiclient.discovery import build

PACKAGE = 'com.schweizerle.gamergrove'
SA = os.environ.get('GG_PLAY_SA',
                    os.path.expanduser('~/gg-play-sa.json'))

creds = service_account.Credentials.from_service_account_file(
    SA, scopes=['https://www.googleapis.com/auth/androidpublisher'])
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)
edits = svc.edits()
eid = edits.insert(packageName=PACKAGE, body={}).execute()['id']
try:
    print('=== TRACKS ===')
    for t in edits.tracks().list(packageName=PACKAGE, editId=eid).execute().get('tracks', []):
        print(f"\n[{t['track']}]")
        for r in t.get('releases', []):
            print(f"  name={r.get('name')!r} status={r.get('status')} "
                  f"codes={r.get('versionCodes')} "
                  f"fraction={r.get('userFraction')} "
                  f"countryTargeting={r.get('countryTargeting')}")
    print('\n=== BUNDLES (uploaded) ===')
    b = edits.bundles().list(packageName=PACKAGE, editId=eid).execute()
    print([x['versionCode'] for x in b.get('bundles', [])])
finally:
    edits.delete(packageName=PACKAGE, editId=eid).execute()
