"""Upload an AAB and put it on the tracks named on the command line.

Production is refused here. It is the one track where a mistake reaches people
who never signed up to test anything, and that step belongs to a person.

Usage: play.py <aab> <track> [track ...] -- <release notes>
"""
import os
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

PACKAGE = 'com.schweizerle.gamergrove'
SA = os.environ.get('GG_PLAY_SA',
                    os.path.expanduser('~/gg-play-sa.json'))
REFUSED = {'production'}


def main() -> int:
    argv = sys.argv[1:]
    notes = ''
    if '--' in argv:
        cut = argv.index('--')
        notes = ' '.join(argv[cut + 1:])
        argv = argv[:cut]

    aab, tracks = argv[0], argv[1:]
    if not tracks:
        print('name at least one track', file=sys.stderr)
        return 1
    for track in tracks:
        if track in REFUSED:
            print(f'{track} is not published by this script', file=sys.stderr)
            return 1

    creds = service_account.Credentials.from_service_account_file(
        SA, scopes=['https://www.googleapis.com/auth/androidpublisher']
    )
    service = build('androidpublisher', 'v3', credentials=creds,
                    cache_discovery=False)
    edits = service.edits()

    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()['id']
    bundle = edits.bundles().upload(
        packageName=PACKAGE, editId=edit_id,
        media_body=MediaFileUpload(aab, mimetype='application/octet-stream',
                                   resumable=True),
    ).execute()
    version = bundle['versionCode']
    print(f'uploaded versionCode {version}')

    release = {
        'name': str(version),
        'versionCodes': [str(version)],
        'status': 'completed',
    }
    if notes:
        release['releaseNotes'] = [{'language': 'en-US', 'text': notes}]

    for track in tracks:
        edits.tracks().update(
            packageName=PACKAGE, editId=edit_id, track=track,
            body={'track': track, 'releases': [release]},
        ).execute()
        print(f'{track} <- {version}')

    # Always. This app has changes waiting in the console's publishing queue,
    # and Play then refuses to send anything for review from the API:
    #   "Changes cannot be sent for review automatically."
    # The build lands on its tracks either way; a person submits the whole
    # batch from the console, which is the right place for that decision.
    edits.commit(packageName=PACKAGE, editId=edit_id,
                 changesNotSentForReview=True).execute()
    print('committed (review is submitted from the console)')

    check = edits.insert(packageName=PACKAGE, body={}).execute()['id']
    try:
        for entry in edits.tracks().list(
            packageName=PACKAGE, editId=check
        ).execute().get('tracks', []):
            for rel in entry.get('releases', []):
                print(f"{entry['track']}: {rel.get('versionCodes')} "
                      f"[{rel.get('status')}]")
    finally:
        edits.delete(packageName=PACKAGE, editId=check).execute()
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
