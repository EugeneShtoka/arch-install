#!/usr/bin/env python3
"""
wa-to-matrix.py — Import WhatsApp chat export (.txt) into a Matrix room.

Uses the mautrix-whatsapp appservice token to backdate messages with correct
timestamps and optionally send as specific Matrix virtual users.

Usage:
  python wa-to-matrix.py <export.txt> <room_id> [options]

Options:
  --dry-run          Parse and print without sending
  --map NAME=@user   Map a WhatsApp display name to a Matrix user ID
                     (can be repeated; unmapped senders use bot with [Name] prefix)
  --delay MS         Delay between requests in ms (default: 50)
  --skip N           Skip first N messages (resume after partial import)

Examples:
  # Dry run to check parsing:
  python wa-to-matrix.py "WhatsApp Chat with John.txt" '!abc123:localhost' --dry-run

  # Real import, send as bot with [Name] prefix:
  python wa-to-matrix.py chat.txt '!abc123:localhost'

  # Map sender names to virtual WA users (get IDs from Element room member list):
  python wa-to-matrix.py chat.txt '!abc123:localhost' \
    --map "John Doe=@whatsapp_1234567890:localhost" \
    --map "Jane=@whatsapp_0987654321:localhost"
"""

import re
import sys
import json
import time
import uuid
import argparse
from datetime import datetime

try:
    import requests
except ImportError:
    print("Missing: pip install requests")
    sys.exit(1)

# ── Config — edit these ───────────────────────────────────────────────────────

# Your homeserver URL (local or VPS)
HOMESERVER = "http://localhost:6167"

# Appservice token — from /etc/tuwunel/tuwunel.toml [global.appservice.whatsapp-bg]
AS_TOKEN = "JlgbB8Tf1TTAl0kjV9s5gImRmTRu3uFtqZlbkUak3kLElv50nhxWVUswt5o6pMGv"

# The bridge bot user (fallback for unmapped senders)
BOT_USER = "@whatsapp-bg-bot:matrix.cloud-surf.com"

# Auto sender map — display name as it appears in the WA export → Matrix user ID
# Both must be in the appservice namespace (whatsapp_bg_*) to support backdated timestamps
SENDER_MAP = {
    "Eugene":       "@whatsapp_bg_lid-181222537961625:matrix.cloud-surf.com",
    "Galina Shtoka": "@whatsapp_bg_972545347460:matrix.cloud-surf.com",
}

# ─────────────────────────────────────────────────────────────────────────────

# WhatsApp exports timestamps in various locale formats
DATE_FORMATS = [
    ("%m/%d/%y, %I:%M %p",    "US 12h short year"),
    ("%m/%d/%Y, %I:%M %p",    "US 12h long year"),
    ("%m/%d/%y, %H:%M",       "US 24h short year"),
    ("%m/%d/%Y, %H:%M",       "US 24h long year"),
    ("%d/%m/%y, %H:%M",       "EU 24h short year"),
    ("%d/%m/%Y, %H:%M",       "EU 24h long year"),
    ("%d/%m/%y, %I:%M %p",    "EU 12h short year"),
    ("%d/%m/%Y, %I:%M %p",    "EU 12h long year"),
    ("%Y-%m-%d, %H:%M:%S",    "ISO"),
]

# Matches: "12/25/23, 10:30 AM - John: message" (all locale variants)
MSG_RE = re.compile(
    r'^(\d{1,2}/\d{1,2}/\d{2,4}),\s+'         # date
    r'(\d{1,2}:\d{2}(?::\d{2})?'               # time HH:MM or HH:MM:SS
    r'(?:[\s\u202f]?[AP]M)?)'                   # optional AM/PM (with narrow no-break space)
    r'\s+-\s+'                                  # separator
    r'([^:]+):\s'                               # sender name
    r'(.*)'                                     # message body (may be empty for media)
)

SYSTEM_RE = re.compile(
    r'^\d{1,2}/\d{1,2}/\d{2,4},\s+\d{1,2}:\d{2}.*-\s+'
    r'(Messages and calls are end-to-end encrypted|'
    r'You were added|.+ was added|.+ left|.+ changed the|'
    r'This message was deleted|null)'
)


def parse_timestamp(date_str, time_str):
    combined = f"{date_str}, {time_str}".strip()
    combined = combined.replace('\u202f', ' ').replace('\u00a0', ' ')
    for fmt, _ in DATE_FORMATS:
        try:
            dt = datetime.strptime(combined, fmt)
            return int(dt.timestamp() * 1000)
        except ValueError:
            continue
    return None


def parse_export(path):
    messages = []
    skipped_system = 0
    current = None

    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.rstrip('\n')

            # Skip BOM or empty lines at start
            if not line.strip():
                continue

            m = MSG_RE.match(line)
            if m:
                if current:
                    messages.append(current)

                date_str, time_str, sender, body = m.groups()
                sender = sender.strip()

                # Skip system messages
                if body in ('<Media omitted>', '') or SYSTEM_RE.match(line):
                    skipped_system += 1
                    current = None
                    continue

                ts = parse_timestamp(date_str, time_str)
                current = {
                    'sender': sender,
                    'body': body,
                    'ts': ts,
                    'raw_date': f"{date_str}, {time_str}",
                }
            elif current:
                # Multi-line message continuation
                current['body'] += '\n' + line

    if current:
        messages.append(current)

    return messages, skipped_system


def send_message(room_id, user_id, body, ts_ms, dry_run=False):
    if dry_run:
        return {"event_id": "dry-run"}

    txn_id = str(uuid.uuid4())
    url = f"{HOMESERVER}/_matrix/client/v3/rooms/{room_id}/send/m.room.message/{txn_id}"
    params = {"user_id": user_id, "ts": ts_ms}
    headers = {
        "Authorization": f"Bearer {AS_TOKEN}",
        "Content-Type": "application/json",
    }
    payload = {"msgtype": "m.text", "body": body}

    resp = requests.put(url, params=params, headers=headers, json=payload, timeout=15)
    resp.raise_for_status()
    return resp.json()


def main():
    parser = argparse.ArgumentParser(description="Import WhatsApp export into Matrix room")
    parser.add_argument("export", help="Path to WhatsApp .txt export file")
    parser.add_argument("room_id", help="Matrix room ID (e.g. !abc123:localhost)")
    parser.add_argument("--dry-run", action="store_true", help="Parse and print without sending")
    parser.add_argument("--map", action="append", metavar="NAME=@user:domain",
                        help="Map WA display name to Matrix user ID (repeatable)")
    parser.add_argument("--delay", type=int, default=50, metavar="MS",
                        help="Delay between requests in ms (default: 50)")
    parser.add_argument("--skip", type=int, default=0, metavar="N",
                        help="Skip first N messages (for resuming)")
    args = parser.parse_args()

    # Build name → matrix user mapping (CLI overrides SENDER_MAP)
    name_map = dict(SENDER_MAP)
    if args.map:
        for entry in args.map:
            if '=' not in entry:
                print(f"Bad --map format (expected NAME=@user:domain): {entry}")
                sys.exit(1)
            name, mxid = entry.split('=', 1)
            name_map[name.strip()] = mxid.strip()

    print(f"Parsing: {args.export}")
    messages, skipped = parse_export(args.export)
    print(f"Found {len(messages)} messages ({skipped} system/media messages skipped)")

    if not messages:
        print("Nothing to import.")
        return

    # Show timestamp detection result
    sample = messages[0]
    ts_ok = sample['ts'] is not None
    print(f"Timestamp sample: '{sample['raw_date']}' → {'OK' if ts_ok else 'FAILED (will use 0)'}")

    # Show unique senders
    senders = sorted(set(m['sender'] for m in messages))
    print(f"\nSenders ({len(senders)}):")
    for s in senders:
        mapped = name_map.get(s)
        count = sum(1 for m in messages if m['sender'] == s)
        print(f"  {s!r} ({count} msgs) → {mapped or f'bot as [{s}]'}")

    if args.dry_run:
        print("\n── Dry run — first 10 messages ──")
        for msg in messages[:10]:
            user = name_map.get(msg['sender'], BOT_USER)
            body = msg['body'] if msg['sender'] in name_map else f"[{msg['sender']}] {msg['body']}"
            ts = datetime.fromtimestamp(msg['ts'] / 1000).strftime('%Y-%m-%d %H:%M') if msg['ts'] else '?'
            print(f"  {ts}  {user}  {body[:80]}")
        return

    if AS_TOKEN == "PASTE_AS_TOKEN_HERE":
        print("\nERROR: Set AS_TOKEN in the script first.")
        print("  sudo cat /etc/mautrix-whatsapp/registration.yaml | grep as_token")
        sys.exit(1)

    to_send = messages[args.skip:]
    print(f"\nSending {len(to_send)} messages to {args.room_id} ...")
    if args.skip:
        print(f"(skipping first {args.skip})")

    failed = 0
    for i, msg in enumerate(to_send):
        abs_i = i + args.skip
        sender = msg['sender']
        user_id = name_map.get(sender, BOT_USER)
        # Only add [Name] prefix for truly unmapped senders (bot fallback)
        body = msg['body'] if user_id != BOT_USER else f"[{sender}] {msg['body']}"
        ts_ms = msg['ts'] or 0

        try:
            send_message(args.room_id, user_id, body, ts_ms)
        except Exception as e:
            print(f"  [ERR #{abs_i}] {e}")
            print(f"    To resume: --skip {abs_i}")
            failed += 1
            if failed >= 5:
                print("Too many errors, stopping.")
                break
            continue

        if i % 100 == 0:
            ts_str = datetime.fromtimestamp(ts_ms / 1000).strftime('%Y-%m-%d %H:%M') if ts_ms else '?'
            print(f"  [{abs_i}/{len(messages)}] {ts_str}  {sender}: {msg['body'][:50]}")

        time.sleep(args.delay / 1000)

    ok = len(to_send) - failed
    print(f"\nDone: {ok}/{len(to_send)} sent, {failed} failed.")


if __name__ == "__main__":
    main()
