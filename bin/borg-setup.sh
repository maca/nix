#!/bin/bash

# Borg Backup Setup Script for Hetzner Storage Box
# This script helps set up SSH keys and initialize the Borg repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Configuration
STORAGE_BOX_USER="u437393"
STORAGE_BOX_HOST="u437393.your-storagebox.de"
SSH_KEY_PATH="$HOME/.ssh/id_rsa_hetzner_backup"
KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts_hetzner"

# Prompt for backup name
echo "Enter a name for your backup repository (e.g., mac-air, documents, home):"
read -p "Backup name: " BACKUP_NAME

# Validate backup name
if [[ -z "$BACKUP_NAME" ]]; then
    error "Backup name cannot be empty"
    exit 1
fi

# Sanitize backup name (remove special characters, convert to lowercase)
BACKUP_NAME=$(echo "$BACKUP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

if [[ -z "$BACKUP_NAME" ]]; then
    error "Invalid backup name after sanitization"
    exit 1
fi

log "Using backup name: $BACKUP_NAME"

echo "=============================================="
echo "    Borg Backup Setup for Hetzner Storage Box"
echo "=============================================="
echo ""

# Step 1: Check if SSH key exists
echo "Step 1: SSH Key Setup"
echo "--------------------"

if [[ -f "$SSH_KEY_PATH" ]]; then
    success "SSH key already exists at $SSH_KEY_PATH"
else
    log "Generating new SSH key for Hetzner Storage Box..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -C "borg-backup-$(hostname)"
    success "SSH key generated at $SSH_KEY_PATH"
fi

# Add key to SSH agent
echo ""
log "Adding SSH key to ssh-agent..."

# Check if ssh-agent is running
if ! pgrep -x "ssh-agent" > /dev/null; then
    log "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
fi

# Add the key to ssh-agent (will prompt for passphrase)
if ssh-add "$SSH_KEY_PATH"; then
    success "SSH key added to ssh-agent"
else
    error "Failed to add SSH key to ssh-agent"
    exit 1
fi

# Step 2: Upload Public Key to Storage Box using ssh-copy-id
echo ""
echo "Step 2: Upload Public Key to Storage Box"
echo "----------------------------------------"

if [[ -f "${SSH_KEY_PATH}.pub" ]]; then
    echo "Public key to be uploaded:"
    echo ""
    echo "=== PUBLIC KEY ==="
    cat "${SSH_KEY_PATH}.pub"
    echo "=== END PUBLIC KEY ==="
    echo ""
    
    log "Attempting to upload SSH key using ssh-copy-id..."
    
    if ssh-copy-id -i "$SSH_KEY_PATH" -p 23 "$STORAGE_BOX_USER@$STORAGE_BOX_HOST" 2>/dev/null; then
        success "SSH key uploaded successfully using ssh-copy-id!"
    else
        warning "Automatic upload failed. Trying manual installation..."
        
        # Try manual installation using Hetzner's install-ssh-key command
        if cat "${SSH_KEY_PATH}.pub" | ssh -p 23 "$STORAGE_BOX_USER@$STORAGE_BOX_HOST" install-ssh-key 2>/dev/null; then
            success "SSH key uploaded successfully using Hetzner's install-ssh-key command!"
        else
            error "Automatic key upload failed. Please upload manually:"
            echo ""
            echo "Option 1 - Use Hetzner's automatic installer:"
            echo "  cat ${SSH_KEY_PATH}.pub | ssh -p 23 $STORAGE_BOX_USER@$STORAGE_BOX_HOST install-ssh-key"
            echo ""
            echo "Option 2 - Manual upload via Robot panel:"
            echo "  1. Log into Robot at https://robot.hetzner.com/"
            echo "  2. Go to your Storage Box settings"
            echo "  3. Enable SSH support if not already enabled"
            echo "  4. Add the above public key in OpenSSH format"
            echo ""
            echo "Option 3 - Manual SCP upload:"
            echo "  ssh -p 23 $STORAGE_BOX_USER@$STORAGE_BOX_HOST mkdir .ssh"
            echo "  scp -P 23 ${SSH_KEY_PATH}.pub $STORAGE_BOX_USER@$STORAGE_BOX_HOST:.ssh/authorized_keys"
            echo ""
            read -p "Press Enter after you've uploaded the public key to continue..."
        fi
    fi
else
    error "Public key file not found"
    exit 1
fi

# Step 3: Test SSH connection
echo ""
echo "Step 3: Testing SSH Connection"
echo "------------------------------"

log "Testing SSH connection to Storage Box..."

# Add host key to known_hosts if it doesn't exist
if ! ssh-keygen -F "[$STORAGE_BOX_HOST]:23" > /dev/null 2>&1; then
    log "Adding Storage Box host key to known_hosts..."
    ssh-keyscan -p 23 -H "$STORAGE_BOX_HOST" >> "$KNOWN_HOSTS_FILE" 2>/dev/null || true
fi

# Test connection (using ssh-agent)
if ssh -p 23 -o ConnectTimeout=10 -o BatchMode=yes "$STORAGE_BOX_USER@$STORAGE_BOX_HOST" pwd > /dev/null 2>&1; then
    success "SSH connection successful!"
else
    error "SSH connection failed. Please check:"
    echo "  - Public key was uploaded correctly to Storage Box"
    echo "  - SSH support is enabled on Storage Box"
    echo "  - Key format is correct (OpenSSH format, not RFC4716)"
    echo "  - SSH key is loaded in ssh-agent (check: ssh-add -l)"
    echo ""
    echo "You can test manually with:"
    echo "  ssh -p 23 $STORAGE_BOX_USER@$STORAGE_BOX_HOST"
    exit 1
fi

# Step 4: Create backup directory on storage box
echo ""
echo "Step 4: Setting up Backup Directory"
echo "-----------------------------------"

log "Creating backup directory on Storage Box..."
if ssh -p 23 "$STORAGE_BOX_USER@$STORAGE_BOX_HOST" "mkdir -p backups/$BACKUP_NAME"; then
    success "Backup directory created successfully"
else
    warning "Could not create backup directory (might already exist)"
fi

# Step 5: Set up environment
echo ""
echo "Step 5: Environment Setup"
echo "------------------------"

# Create borg passphrase if it doesn't exist
BORG_PASSPHRASE_FILE="$HOME/.config/borg/passphrase"
if [[ ! -f "$BORG_PASSPHRASE_FILE" ]]; then
    log "Generating Borg repository passphrase..."
    mkdir -p "$(dirname "$BORG_PASSPHRASE_FILE")"
    
    # Generate a strong passphrase
    PASSPHRASE=$(openssl rand -base64 32)
    echo "$PASSPHRASE" > "$BORG_PASSPHRASE_FILE"
    chmod 600 "$BORG_PASSPHRASE_FILE"
    
    success "Passphrase generated and saved to $BORG_PASSPHRASE_FILE"
    warning "IMPORTANT: Back up this passphrase file! Without it, you cannot access your backups!"
else
    success "Passphrase file already exists"
fi

# Step 6: Initialize Borg repository
echo ""
echo "Step 6: Initialize Borg Repository"
echo "----------------------------------"

# Set environment variables for borg
export BORG_PASSPHRASE_FILE
export BORG_REPO="ssh://$STORAGE_BOX_USER@$STORAGE_BOX_HOST:23/./backups/$BACKUP_NAME"
export BORG_REMOTE_PATH="borg-1.4"

log "Initializing Borg repository..."
BORG_PASSPHRASE=$(cat "$BORG_PASSPHRASE_FILE")
export BORG_PASSPHRASE

if borg info --remote-path="$BORG_REMOTE_PATH" "$BORG_REPO" &>/dev/null; then
    warning "Repository already exists"
else
    if borg init --encryption=repokey --remote-path="$BORG_REMOTE_PATH" "$BORG_REPO"; then
        success "Repository initialized successfully"
    else
        error "Failed to initialize repository"
        exit 1
    fi
fi

# Step 7: Environment variables setup
echo ""
echo "Step 7: Environment Variables"
echo "----------------------------"

ENV_FILE="$HOME/.config/borg/environment"
cat > "$ENV_FILE" << EOF
# Borg Backup Environment Variables
export BORG_REPO="ssh://$STORAGE_BOX_USER@$STORAGE_BOX_HOST:23/./backups/$BACKUP_NAME"
export BORG_REMOTE_PATH="borg-1.4"
export BORG_PASSPHRASE_FILE="$BORG_PASSPHRASE_FILE"

# SSH key is automatically used via ssh-agent
# BORG_RSH is not needed when using ssh-agent
EOF

success "Environment file created at $ENV_FILE"

# Step 8: Test backup
echo ""
echo "Step 8: Test Backup"
echo "------------------"

log "Running test backup..."
source "$ENV_FILE"

# Test with a small directory
TEST_DIR="$HOME/.config/borg"
ARCHIVE_NAME="test-$(date +%Y%m%d-%H%M%S)"

if borg create --stats --remote-path="$BORG_REMOTE_PATH" "$BORG_REPO::$ARCHIVE_NAME" "$TEST_DIR"; then
    success "Test backup completed successfully!"
    
    # Clean up test archive
    borg delete --remote-path="$BORG_REMOTE_PATH" "$BORG_REPO::$ARCHIVE_NAME"
    log "Test archive cleaned up"
else
    error "Test backup failed"
    exit 1
fi

# Final instructions
echo ""
echo "=============================================="
echo "              Setup Complete!"
echo "=============================================="
echo ""
success "Borg backup is now configured and ready to use!"
echo ""
echo "Quick start:"
echo "  Source environment: source $ENV_FILE"
echo "  List backup keys:   borg-backup keys"
echo "  Create backup:      borg-backup backup"
echo "  List archives:      borg-backup list"
echo "  Start auto-backup:  borg-service start"
echo ""
echo "Important files:"
echo "  SSH Key:            $SSH_KEY_PATH"
echo "  Passphrase:         $BORG_PASSPHRASE_FILE"
echo "  Environment:        $ENV_FILE"
echo "  Config:             $HOME/.config/borg/backup-dirs.conf"
echo ""
warning "BACKUP YOUR PASSPHRASE FILE! Store it safely offline."
echo ""
echo "Repository URL: $BORG_REPO"
