"""Put an already-uploaded versionCode on the test tracks.

No upload: assigns the bundle that is already there, so alpha and beta serve
byte-for-byte what production serves. Production is not touched here.
"""
import os, sys
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

PACKAGE = 'com.schweizerle.gamergrove'
code = sys.argv[1]
creds = service_account.Credentials.from_service_account_file(
    os.path.expanduser('~/gg-play-sa.json'),
    scopes=['https://www.googleapis.com/auth/androidpublisher'])
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)
edits = svc.edits()
edit_id = edits.insert(packageName=PACKAGE, body={}).execute()['id']

for track in ('alpha', 'beta'):
    edits.tracks().update(
        packageName=PACKAGE, editId=edit_id, track=track,
        body={'track': track, 'releases': [
            {'versionCodes': [code], 'status': 'completed'}]},
    ).execute()
    print(f'{track} <- {code}')

try:
    edits.commit(packageName=PACKAGE, editId=edit_id).execute()
    print('committed and sent for review')
except HttpError as err:
    if 'changesNotSentForReview' not in str(err):
        raise
    edits.commit(packageName=PACKAGE, editId=edit_id,
                 changesNotSentForReview=True).execute()
    print('committed (submit from the console)')
