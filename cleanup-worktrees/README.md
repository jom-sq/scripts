# Cleanup Worktrees

Automatically removes git worktrees that haven't been modified in X days.

## How It Works

The script scans `~/Development/worktrees/<repo>/` for worktree directories. If no files (excluding `.git/`) have been modified within the threshold period, the worktree is removed and `git worktree prune` is run on the main repo.

## Setup

### 1. Install the script

```bash
mkdir -p ~/bin
cp cleanup-worktrees.sh ~/bin/
chmod +x ~/bin/cleanup-worktrees.sh
```

### 2. Create the launchd plist

Create `~/Library/LaunchAgents/com.<LDAP>.cleanup-worktrees.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.<LDAP>.cleanup-worktrees</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/<LDAP>/bin/cleanup-worktrees.sh</string>
        <string>4</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/<LDAP>/.local/logs/worktree-cleanup-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/<LDAP>/.local/logs/worktree-cleanup-stderr.log</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
```

Replace `<LDAP>` with your username. Change `4` to your preferred threshold in days.

### 3. Load the job

```bash
mkdir -p ~/.local/logs
launchctl load ~/Library/LaunchAgents/com.<LDAP>.cleanup-worktrees.plist
```

## Usage

```bash
# Preview what would be deleted (dry run)
cleanup-worktrees.sh 4 --dry-run

# Remove worktrees older than 4 days
cleanup-worktrees.sh 4

# Remove worktrees older than 7 days
cleanup-worktrees.sh 7
```

## Commands

| Action | Command |
|--------|---------|
| Load job | `launchctl load ~/Library/LaunchAgents/com.<LDAP>.cleanup-worktrees.plist` |
| Unload job | `launchctl unload ~/Library/LaunchAgents/com.<LDAP>.cleanup-worktrees.plist` |
| Test now | `launchctl start com.<LDAP>.cleanup-worktrees` |
| Check status | `launchctl list \| grep cleanup-worktrees` |
| View logs | `cat ~/.local/logs/worktree-cleanup.log` |

## Expected Directory Structure

```
~/Development/
├── my-repo/                      # Main clone
└── worktrees/
    └── my-repo/
        ├── feature-a/            # Worktree (will be cleaned if stale)
        └── feature-b/            # Worktree
```
