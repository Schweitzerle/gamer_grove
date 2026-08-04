"""Put an already-uploaded versionCode on the production track at 100%.

Separate from play.py, which refuses production on purpose. This script exists
because of one specific, verified reason: Play's Photo-and-Video-Permissions
check runs over every version code that is live on any track, and versionCode 5
— the release still serving production — predates the removal of
READ_MEDIA_IMAGES. No other track can clear that finding; the only way to take 5
off production is to supersede it.

No upload. It assigns a bundle that is already on the tracks, so what goes to
production is byte-for-byte what alpha and beta were tested with.
"""
import os
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

PACKAGE = 'com.schweizerle.gamergrove'
SA = os.environ.get('GG_PLAY_SA',
                    os.path.expanduser('~/gg-play-sa.json'))

NOTES = (
    'A rebuilt GamerGrove. New look and app icon, a Grove and game pages lit '
    'by the covers themselves, custom collections, and GamerGrove Pro for '
    'stats, advanced filters, themes and unlimited collections. Your account '
    'can now be deleted from inside the app. Game data runs through our own '
    'server, and the profile picture uses the Android photo picker — the app '
    'no longer asks to read your gallery.'
)


def main() -> int:
    version = sys.argv[1]

    creds = service_account.Credentials.from_service_account_file(
        SA, scopes=['https://www.googleapis.com/auth/androidpublisher'])
    edits = build('androidpublisher', 'v3', credentials=creds,
                  cache_discovery=False).edits()
    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()['id']

    uploaded = [str(b['versionCode']) for b in
                edits.bundles().list(packageName=PACKAGE,
                                     editId=edit_id).execute().get('bundles', [])]
    if version not in uploaded:
        print(f'{version} was never uploaded; have {uploaded}', file=sys.stderr)
        edits.delete(packageName=PACKAGE, editId=edit_id).execute()
        return 1

    edits.tracks().update(
        packageName=PACKAGE, editId=edit_id, track='production',
        body={'track': 'production', 'releases': [{
            'name': f'{version} (2.0.2)',
            'versionCodes': [version],
            'status': 'completed',          # 100% — a staged rollout would
                                            # leave 5 serving the remainder,
                                            # and the finding with it.
            'releaseNotes': [{'language': 'en-US', 'text': NOTES}],
        }]},
    ).execute()

    # Play flips this flag's legality depending on what is queued in the
    # console, and rejects the wrong choice with a 400 either way:
    #   queued changes    -> "Changes cannot be sent for review automatically."
    #                        (the flag is required)
    #   nothing queued    -> "Changes are sent for review automatically.
    #                        The query parameter must not be set."
    # So ask by trying, rather than guessing at the console's state.
    try:
        edits.commit(packageName=PACKAGE, editId=edit_id).execute()
        print(f'production <- {version} (100%), sent for review')
    except HttpError as err:
        if 'changesNotSentForReview' not in str(err):
            raise
        edits.commit(packageName=PACKAGE, editId=edit_id,
                     changesNotSentForReview=True).execute()
        print(f'production <- {version} (100%), submit it from the console')

    check = edits.insert(packageName=PACKAGE, body={}).execute()['id']
    try:
        for t in edits.tracks().list(packageName=PACKAGE,
                                     editId=check).execute().get('tracks', []):
            for r in t.get('releases', []):
                print(f"{t['track']}: {r.get('versionCodes')} "
                      f"[{r.get('status')}] fraction={r.get('userFraction')}")
    finally:
        edits.delete(packageName=PACKAGE, editId=check).execute()
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
