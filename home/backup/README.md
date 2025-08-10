# Hetzner Storage Box Backup with Borg

This configuration sets up automated backups to your Hetzner storage box using BorgBackup.

## Features

- **Directory mapping**: Configure which directories to backup with easy-to-remember keys
- **SSH key management**: Automatic SSH key generation and configuration
- **Borg wrapper script**: Simple commands for all backup operations
- **Automated scheduling**: Daily backups via systemd (Linux) or launchd (macOS)
- **Platform independent**: Works on both Linux and macOS

## Setup Instructions

### 1. Generate and Install SSH Key

```bash
# Generate SSH key for Hetzner storage box
setup-hetzner-ssh

# The script will output your public key. Copy it and install on Hetzner:
cat ~/.ssh/hetzner_backup.pub | ssh -p23 u437393@u437393.your-storagebox.de install-ssh-key
```

### 2. Initialize Repositories

For each directory you want to backup:

```bash
# Initialize repository for documents
borg-backup init documents

# Add more directories by editing the backupDirs in default.nix
```

### 3. Configure Directory Mappings

Edit `/Users/maca/nix/home/backup/default.nix` and modify the `backupDirs` section:

```nix
backupDirs = {
  documents = "~/Documentos";
  home = "~";                    # Add full home backup
  config = "~/.config";          # Add config backup
  projects = "~/Projects";       # Add projects backup
};
```

After adding directories, rebuild your Nix configuration and initialize the new repositories.

## Usage

### Basic Operations

```bash
# Create backup
borg-backup backup documents

# List all archives
borg-backup list documents

# Show repository info
borg-backup info documents

# Show specific archive info
borg-backup info documents documents-20250607-143022

# Mount repository for browsing
borg-backup mount documents /tmp/backup-mount

# Extract specific archive
borg-backup extract documents documents-20250607-143022 /tmp/restore

# Prune old archives (keeps: 7 daily, 4 weekly, 6 monthly)
borg-backup prune documents
```

### Help

```bash
borg-backup
# Shows usage information and available directory keys
```

## Automated Backups

- **Linux**: Uses systemd user services and timers
- **macOS**: Uses launchd agents
- **Schedule**: Daily at 2 AM (with randomized delay on Linux)
- **Logs**: Check `~/.local/var/log/borg-backup-<dir-key>.log` on macOS

### Managing Automated Backups

Linux (systemd):
```bash
# Check service status
systemctl --user status borg-backup-documents.service

# View logs
journalctl --user -u borg-backup-documents.service

# Enable/disable timer
systemctl --user enable borg-backup-documents.timer
systemctl --user disable borg-backup-documents.timer
```

macOS (launchd):
```bash
# Check if agent is loaded
launchctl list | grep borg-backup

# View logs
tail -f ~/.local/var/log/borg-backup-documents.log
```

## Security Features

- **SSH key with passphrase**: The setup script generates a key with passphrase protection
- **SSH agent integration**: Keys are automatically loaded into ssh-agent when needed
- **Repository encryption**: Uses repokey-blake2 encryption for all repositories
- **Secure defaults**: Excludes sensitive files and uses compression

## Backup Strategy

The configuration implements a 3-2-1 backup strategy component:
- **3**: Multiple archive versions (daily, weekly, monthly retention)
- **2**: Local source + remote Hetzner storage
- **1**: Offsite storage (Hetzner datacenter)

Retention policy:
- Keep 7 daily backups
- Keep 4 weekly backups  
- Keep 6 monthly backups

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection
ssh -p23 u437393@u437393.your-storagebox.de

# Check SSH key is loaded
ssh-add -l

# Add key to agent if needed
ssh-add ~/.ssh/hetzner_backup
```

### Repository Issues

```bash
# Check repository integrity
borg check ssh://u437393@u437393.your-storagebox.de:23/./backups/documents

# Repair repository (use with caution)
borg check --repair ssh://u437393@u437393.your-storagebox.de:23/./backups/documents
```

### Storage Box Limits

- Hetzner storage boxes have bandwidth and connection limits
- Large initial backups may take time
- Subsequent backups are incremental and much faster

## Adding New Directories

1. Edit `backupDirs` in `default.nix`
2. Rebuild Nix configuration: `home-manager switch`
3. Initialize new repository: `borg-backup init <new-key>`
4. Test backup: `borg-backup backup <new-key>`