# NeoMutt Gmail Setup

## Stack

| Component | Role |
|-----------|------|
| **gmailieer** (`gmi`) | Gmail API OAuth2 sync — bidirectional tag↔label |
| **notmuch** | Mail indexer; all mailboxes are virtual queries |
| **neomutt** | MUA; reads notmuch virtual mailboxes |
| **goimapnotify** | IMAP IDLE watcher; triggers `gmi sync` on new mail |
| **msmtp** | SMTP sending |
| **mutt_oauth2.py** | OAuth2 token manager (GPG-encrypted) |

---

## File Paths

| File | Path |
|------|------|
| Mail dir (gmailieer root) | `~/.local/share/mail/e.shtoka@gmail.com/` |
| Maildir | `~/.local/share/mail/e.shtoka@gmail.com/mail/` |
| Notmuch config | `~/.notmuch-config` |
| Neomutt main config | `~/.config/mutt/muttrc` |
| Account config | `~/.config/mutt/accounts/e.shtoka@gmail.com.muttrc` |
| Theme | `~/.config/mutt/cobalt2.muttrc` |
| OAuth2 token (GPG) | `~/.cache/mutt_oauth2/e.shtoka@gmail.com.gpg` |
| mutt_oauth2.py | `~/.scripts/mutt_oauth2.py` |
| gmi-push script | `~/.scripts/gmi-push.sh` |
| goimapnotify config | `~/.config/goimapnotify/goimapnotify.json` |
| goimapnotify override | `~/.config/systemd/user/goimapnotify@.service.d/override.conf` |
| gmi-push systemd service | `~/.config/systemd/user/gmi-push.service` |
| gmi-push systemd timer | `~/.config/systemd/user/gmi-push.timer` |
| gmailieer config | `~/.local/share/mail/e.shtoka@gmail.com/.gmailieer.json` |
| gmailieer state | `~/.local/share/mail/e.shtoka@gmail.com/.state.gmailieer.json` |

---

## Auth: OAuth2 Everywhere (no app passwords)

### gmailieer
- Own Google Cloud project, credentials at `.credentials.gmailieer.json`

### msmtp + goimapnotify
- Reuse gmailieer's `client_id`/`client_secret` via `mutt_oauth2.py`
- Token at `~/.cache/mutt_oauth2/e.shtoka@gmail.com.gpg` (GPG-encrypted)
- Scope: `https://mail.google.com/`
- Flow: `localhostauthcode` — **NOT** `devicecode` (gmailieer's GCP client is "Web app" type; devicecode fails with "invalid client type")
- Token auto-refreshes on use; re-authorize only if revoked

**msmtp**: `auth oauthbearer`, `passwordeval "python3 ~/.scripts/mutt_oauth2.py ~/.cache/mutt_oauth2/e.shtoka@gmail.com.gpg"`

**goimapnotify**: `"passwordCMD": "python3 ~/.scripts/mutt_oauth2.py ..."`, `"xoauth2": true`

---

## Notmuch Config (`~/.notmuch-config`)

```ini
[database]
path = ~/.local/share/mail

[new]
tags =              # empty — gmailieer handles all tags from Gmail

[search]
exclude_tags = deleted;spam;trash

[maildir]
synchronize_flags = false   # CRITICAL — prevents mass re-push via gmailieer
```

---

## Virtual Mailboxes

Defined in `~/.config/mutt/accounts/e.shtoka@gmail.com.muttrc`:

| Name | Query |
|------|-------|
| Inbox | `tag:inbox AND NOT tag:trash AND NOT tag:spam` |
| Unread | `tag:unread` |
| Sent | `tag:sent` |
| Drafts | `tag:draft` |
| Trash | `tag:trash` |
| Archive | `tag:/[A-Z].*/` (custom Gmail labels) |

---

## Key Bindings (`~/.config/mutt/muttrc`)

Bindings must be placed **after all `source` lines** — mutt-wizard sets `bind index D delete-message`; the `unbind` + placement below overrides it.

```muttrc
unbind index D
macro index,pager D "<modify-labels>+trash -inbox\n<quasi-delete>" "delete message"
macro index,pager l "<modify-labels>" "modify labels"
```

- **D** — tags `+trash -inbox`, removes message from view immediately via `<quasi-delete>`
- **l** — opens label editor for arbitrary tag changes
- **R** — reload inbox (re-executes notmuch query, hides messages no longer matching)
- **o** (account file) — `gmi sync && notmuch new` (full sync)

### Why `<change-folder>!<enter>` at the end of D
Re-executes the inbox notmuch query (`spool_file`). The deleted message no longer matches `tag:inbox AND NOT tag:trash AND NOT tag:spam` so it disappears immediately. `<modify-labels-then-hide>` was tried first but only hides when a manual `<limit>` is active in neomutt.

### Why no `<shell-escape>` in D/l macros
`<shell-escape>` suspends neomutt's TUI (ncurses `endwin`/`refresh`) regardless of command duration — causes a visible flash and overrides any preceding `<quasi-delete>` state on redraw. Push is handled by the systemd timer instead.

### Why `<sync-mailbox>` must NOT be in the D macro
`<sync-mailbox>` advances the notmuch DB revision and neomutt syncs its internal state, causing `state.lastmod == DB.rev`. `gmi push` then sees no changed messages and does nothing.

---

## gmi-push Script (`~/.scripts/gmi-push.sh`)

```zsh
#!/bin/zsh
mail_dir=~/.local/share/mail/e.shtoka@gmail.com/mail
moved=0
for f in $mail_dir/new/*(N); do
    mv "$f" $mail_dir/cur/"${f:t}:2,"
    moved=1
done
(( moved )) && notmuch new 2>/dev/null
cd ~/.local/share/mail/e.shtoka@gmail.com && gmi push -q >/dev/null 2>&1
```

**Why the `new/` migration**: Files occasionally appear in `mail/new/` without a maildir `:2,` suffix. `gmi push` prints "does not contain valid maildir delimiter" and aborts for ALL changed messages, not just that file. Moving them to `cur/` with `:2,` and reindexing with `notmuch new` clears this before every push.

---

## Systemd Push Timer

`gmi-push.service` / `gmi-push.timer` — fires every 30 seconds, runs `gmi-push.sh`.

```
systemctl --user enable --now gmi-push.timer
```

This replaces the old approach of triggering push via `<shell-escape>` from the D macro.

---

## goimapnotify

Watches Gmail INBOX via IMAP IDLE. On new mail: `gmi sync && notmuch new`, then sends a dunst notification. Runs as `goimapnotify@e.shtoka@gmail.com.service`.

Config must be `.json` extension (not `.conf`/`.yaml`).

```
systemctl --user enable --now goimapnotify@e.shtoka@gmail.com
```

---

## gmailieer Config (`.gmailieer.json`)

Notable settings:
- `ignore_remote_labels`: CATEGORY_* labels are not synced as notmuch tags
- `local_trash_tag`: `"trash"` — maps Gmail Trash to notmuch `trash` tag
- `remove_local_messages`: `true` — gmi pull deletes local messages removed from Gmail
- `synchronize_flags`: controlled by notmuch, not here — set to `false` in `.notmuch-config`

---

## Known Issues / Status

### `mail/new/` files (RESOLVED)
`gmi-push.sh` migrates `new/*` → `cur/*:2,` before every push.

### D macro: message stays visible (RESOLVED)
`<change-folder>!<enter>` at end of macro re-executes inbox query; deleted message no longer matches and disappears.

### D macro: terminal flash (RESOLVED)
`<shell-escape>` removed from D/l macros. Push handled by systemd timer.

### D macro: deletions not reaching Gmail (UNDER INVESTIGATION)
**Symptom**: `gmi push` reports "everything up-to-date" after pressing D, meaning `state.lastmod == DB.rev` at push time — no changed messages detected.  
**Likely cause**: something advances the notmuch DB revision after `<modify-labels>` writes the tag change, without incrementing `state.lastmod` past the new rev. Or the tag write itself is not committing before the push runs.  
**Current mitigation**: the 30s systemd timer may catch deferred changes.  
**Next**: test by pressing D, immediately running `notmuch search --output=messages lastmod:$(python3 -c "import json; print(json.load(open('/home/eugene/.local/share/mail/e.shtoka@gmail.com/.state.gmailieer.json'))['lastmod'])")+1..` to confirm whether the tag change is in notmuch before the timer fires.
