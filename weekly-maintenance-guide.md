# Automating Weekly Laptop Maintenance with launchd

A guide to automatically running `brew update`, `brew upgrade`, and `compost <ROLE>` on a schedule.

## What is launchd?

launchd is macOS's native task scheduler (like cron, but Apple's preferred way). You define jobs in `.plist` files, and macOS runs them on your schedule—even surviving reboots.

---

## Setup

### 1. Create the maintenance script

Create `~/bin/weekly-maintenance.sh`:

```bash
mkdir -p ~/bin
cat > ~/bin/weekly-maintenance.sh << 'EOF'
#!/bin/bash
set -e

echo "========================================"
echo "Started: $(date)"
echo "========================================"

echo ""
echo ">>> brew update"
/opt/homebrew/bin/brew update

echo ""
echo ">>> brew upgrade"
/opt/homebrew/bin/brew upgrade

echo ""
echo ">>> topsoil compost"
cd ~/Development/topsoil
git pull
./compost <ROLE>

echo ""
echo "========================================"
echo "Finished: $(date)"
echo "========================================"
EOF

chmod +x ~/bin/weekly-maintenance.sh
```

Replace `<ROLE>` with your role (e.g., `frontend`, `backend`, `ios`, `android`, etc.).

> **Note:** Run `./compost <ROLE> --default` once manually so it remembers your role and doesn't prompt interactively.

### 2. Create the launchd plist

Create `~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.<LDAP>.weekly-maintenance</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/<LDAP>/bin/weekly-maintenance.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>1</integer>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/weekly-maintenance.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/weekly-maintenance.log</string>
</dict>
</plist>
```

Replace `<LDAP>` with your username (e.g., `jsmith`).

#### Schedule options

| Field | Values |
|-------|--------|
| `Weekday` | 0=Sunday, 1=Monday, ... 6=Saturday |
| `Hour` | 0-23 (24-hour format) |
| `Minute` | 0-59 |

---

## Managing the job

### Load (register the job)

```bash
launchctl load ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist
```

This tells launchd to start managing the job. It will auto-load on future logins.

### Unload (stop scheduling)

```bash
launchctl unload ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist
```

### Check if it's loaded

```bash
launchctl list | grep weekly-maintenance
```

### Run it manually (for testing)

```bash
launchctl start com.<LDAP>.weekly-maintenance
```

---

## Logs

Output goes to `/tmp/weekly-maintenance.log`.

```bash
# View the full log
cat /tmp/weekly-maintenance.log

# Follow live (useful when testing)
tail -f /tmp/weekly-maintenance.log
```

---

## Troubleshooting

**Job not running?**
- Make sure your laptop is awake at the scheduled time
- Check if the job is loaded: `launchctl list | grep weekly-maintenance`
- Check logs for errors: `cat /tmp/weekly-maintenance.log`

**PATH issues?**
- Use full paths in the script (e.g., `/opt/homebrew/bin/brew` instead of `brew`)

**Interactive prompts hanging?**
- Run commands with `--default` or `-y` flags to skip prompts
- launchd has no terminal, so interactive input won't work

---

## Quick reference

| Action | Command |
|--------|---------|
| Load job | `launchctl load ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist` |
| Unload job | `launchctl unload ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist` |
| Test now | `launchctl start com.<LDAP>.weekly-maintenance` |
| Check status | `launchctl list \| grep weekly-maintenance` |
| View logs | `cat /tmp/weekly-maintenance.log` |
