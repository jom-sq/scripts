# Weekly Maintenance

Automatically runs `brew update`, `brew upgrade`, and `topsoil compost` on a schedule.

## Setup

### 1. Install the script

```bash
mkdir -p ~/bin
cp weekly-maintenance.sh ~/bin/
chmod +x ~/bin/weekly-maintenance.sh
```

### 2. Run topsoil once manually

So it remembers your role and doesn't prompt interactively:

```bash
cd ~/Development/topsoil
./compost <ROLE> --default
```

Replace `<ROLE>` with your role (e.g., `frontend`, `backend`, `ios`, `android`).

### 3. Create the launchd plist

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
    <string>/Users/<LDAP>/.local/logs/weekly-maintenance.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/<LDAP>/.local/logs/weekly-maintenance.log</string>
</dict>
</plist>
```

Replace `<LDAP>` with your username.

### 4. Load the job

```bash
mkdir -p ~/.local/logs
launchctl load ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist
```

## Schedule Options

| Field | Values |
|-------|--------|
| `Weekday` | 0=Sunday, 1=Monday, ... 6=Saturday |
| `Hour` | 0-23 (24-hour format) |
| `Minute` | 0-59 |

## Commands

| Action | Command |
|--------|---------|
| Load job | `launchctl load ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist` |
| Unload job | `launchctl unload ~/Library/LaunchAgents/com.<LDAP>.weekly-maintenance.plist` |
| Test now | `launchctl start com.<LDAP>.weekly-maintenance` |
| Check status | `launchctl list \| grep weekly-maintenance` |
| View logs | `cat ~/.local/logs/weekly-maintenance.log` |

## Troubleshooting

- **Job not running?** Make sure your laptop is awake at the scheduled time
- **PATH issues?** Use full paths in the script (e.g., `/opt/homebrew/bin/brew`)
- **Interactive prompts hanging?** Run commands with `--default` or `-y` flags
