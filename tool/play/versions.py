"""Read the active-install distribution per versionCode from Play's bulk reports.

This number is not in the Developer API. It lives in a Cloud Storage bucket whose
name contains the developer account id, and finding that id cost a round trip to
the user once — so it is written down here.

The bucket is served by a Google-owned project, which is why `buckets.list` on
our own project returns 403 and looks like missing access: you address the bucket
by name or not at all.

It answers exactly one recurring question: is versionCode N still in the field?
The IGDB secret may not be rotated while builds that predate the proxy are still
running, and only this file says whether they are.

Usage: versions.py [versionCode]     # no argument -> latest month, all versions
"""
import csv
import gzip
import io
import subprocess
import sys

PACKAGE = 'com.schweizerle.gamergrove'
BUCKET = 'gs://pubsite_prod_9126534664213547209'
PREFIX = f'{BUCKET}/stats/installs/installs_{PACKAGE}'

# Play writes these reports as UTF-16 with a BOM, not UTF-8. Decoding as UTF-8
# yields NUL-separated mojibake that csv parses into nonsense columns rather
# than failing, so the encoding is pinned instead of sniffed.
ENCODING = 'utf-16'

ACTIVE = 'Active Device Installs'
VERSION = 'App Version Code'
DATE = 'Date'


def _gcloud(*args: str) -> bytes:
    result = subprocess.run(
        ('gcloud', 'storage', *args),
        capture_output=True,
        env={
            'CLOUDSDK_CORE_DISABLE_PROMPTS': '1',
            'PATH': '/usr/bin:/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin',
        },
    )
    if result.returncode != 0:
        sys.exit(
            f'gcloud failed: {result.stderr.decode(errors="replace").strip()}\n\n'
            'The service account needs "View app information and download bulk '
            'reports" set to Global in Play Console, and gcloud must be '
            'authenticated with it:\n'
            '  gcloud auth activate-service-account --key-file=~/gg-play-sa.json'
        )
    return result.stdout


def _text(payload: bytes) -> str:
    """Decode a report body.

    Objects are stored gzipped, and `storage cat` hands them over compressed
    while `storage cp` transparently decompresses — so the same file arrives in
    two different shapes depending on how it was fetched. Sniff the magic bytes
    rather than depending on which one the caller used.
    """
    if payload[:2] == b'\x1f\x8b':
        payload = gzip.decompress(payload)
    return payload.decode(ENCODING)


def latest_report() -> str:
    listing = _gcloud('ls', f'{PREFIX}_*_app_version.csv').decode()
    files = sorted(line for line in listing.split() if line.endswith('.csv'))
    if not files:
        sys.exit(f'no app_version reports under {PREFIX}')
    return files[-1]


def rows(uri: str) -> list[dict[str, str]]:
    return list(csv.DictReader(io.StringIO(_text(_gcloud('cat', uri)))))


def main() -> int:
    wanted = sys.argv[1] if len(sys.argv) > 1 else None
    uri = latest_report()
    print(f'==> {uri.rsplit("/", 1)[-1]}')

    report = rows(uri)
    if not report:
        sys.exit('report is empty')

    # The last dated row is the freshest state; earlier rows are that month's
    # daily history. Play lags a day or two, and the current month's file only
    # appears once the month is under way — so "latest" is not "today".
    last = max(row[DATE] for row in report)
    current = {
        row[VERSION]: int(row[ACTIVE] or 0)
        for row in report
        if row[DATE] == last and int(row[ACTIVE] or 0) > 0
    }

    print(f'    as of {last}\n')
    for code, installs in sorted(current.items(), key=lambda kv: -kv[1]):
        print(f'    versionCode {code:>4}   {installs:>5} active device installs')
    print(f'\n    total {sum(current.values())} across {len(current)} versions')

    if wanted is not None:
        live = current.get(wanted, 0)
        print(f'\n==> versionCode {wanted}: {live} active device installs')
        print(
            '    the rotation gate is open' if live == 0
            else f'    rotating now would cut off {live} installation(s) until they update'
        )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
