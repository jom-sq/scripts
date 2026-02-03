# Scripts

A collection of automation scripts for macOS development workflows.

## Scripts

| Script | Description |
|--------|-------------|
| [cleanup-worktrees](./cleanup-worktrees/) | Automatically removes stale git worktrees |
| [weekly-maintenance](./weekly-maintenance/) | Runs brew update/upgrade and topsoil compost on a schedule |

## Installation

Each script has its own folder with:
- The executable script (`.sh`)
- A `README.md` with setup instructions and launchd plist examples

## Quick Start

```bash
# Clone the repo
git clone https://github.com/jom-sq/scripts.git

# Install a script
mkdir -p ~/bin
cp scripts/<script-name>/<script-name>.sh ~/bin/
chmod +x ~/bin/<script-name>.sh

# Follow the README in each folder to set up launchd scheduling
```
