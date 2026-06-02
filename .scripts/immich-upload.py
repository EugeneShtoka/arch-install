#!/usr/bin/env python3
import os, sys, json, hashlib, datetime, mimetypes, urllib.request, urllib.error

IMMICH_URL = "https://immich.cloud-surf.com"
API_KEY = "Jo96b47uH02oAJ0WxGneGG3PlNWnLTYV7Myd7g0OJjU"
FILES_LIST = "/tmp/missing_local_paths.txt"

def sha1(path):
    h = hashlib.sha1()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()

def upload(path):
    stat = os.stat(path)
    mtime = datetime.datetime.fromtimestamp(stat.st_mtime, tz=datetime.timezone.utc)
    ts = mtime.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    filename = os.path.basename(path)
    device_asset_id = f"{filename}-{int(stat.st_mtime)}-{stat.st_size}"
    mime = mimetypes.guess_type(path)[0] or 'application/octet-stream'

    boundary = '----ImmichUploadBoundary'
    def field(name, value):
        return (f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n').encode()

    with open(path, 'rb') as f:
        file_data = f.read()

    body = b''
    body += field('deviceAssetId', device_asset_id)
    body += field('deviceId', 'upload-script')
    body += field('fileCreatedAt', ts)
    body += field('fileModifiedAt', ts)
    body += field('isFavorite', 'false')
    body += f'--{boundary}\r\nContent-Disposition: form-data; name="assetData"; filename="{filename}"\r\nContent-Type: {mime}\r\n\r\n'.encode()
    body += file_data
    body += f'\r\n--{boundary}--\r\n'.encode()

    req = urllib.request.Request(
        f'{IMMICH_URL}/api/assets',
        data=body,
        headers={
            'x-api-key': API_KEY,
            'Content-Type': f'multipart/form-data; boundary={boundary}',
        },
        method='POST'
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            result = json.loads(resp.read())
            return result.get('status', 'unknown'), result.get('id', '')
    except urllib.error.HTTPError as e:
        return f'HTTP {e.code}', e.read().decode()[:200]

files = [l.strip() for l in open(FILES_LIST) if l.strip()]
total = len(files)
ok = dupes = errors = 0

for i, path in enumerate(files, 1):
    status, info = upload(path)
    if status == 'created':
        ok += 1
        print(f'[{i}/{total}] uploaded: {os.path.basename(path)}')
    elif status == 'duplicate':
        dupes += 1
        print(f'[{i}/{total}] duplicate: {os.path.basename(path)}')
    else:
        errors += 1
        print(f'[{i}/{total}] ERROR {status}: {os.path.basename(path)} — {info}')

print(f'\nDone: {ok} uploaded, {dupes} duplicates, {errors} errors')
