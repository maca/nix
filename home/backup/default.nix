{ pkgs, lib, config, ... }:

let
  # Directory mapping for backups
  backupDirs = {
    documents = "~/Documentos";
    fotos = "/Volumes/Fotos/Fotos/Fotos";
    capture = "~/Desktop/Capture";
    # Add more directories here as needed
    # home = "~";
    # config = "~/.config";
  };

  # Hetzner storage box configuration
  storageBox = {
    host = "u437393.your-storagebox.de";
    port = "23";
    user = "u437393";
    sshKey = "${config.home.homeDirectory}/.ssh/id_rsa_hetzner_backup";
  };

  # Borg wrapper script
  borgWrapper = pkgs.writeShellScript "borg-backup" ''
    set -euo pipefail

    # Configuration
    STORAGE_HOST="${storageBox.host}"
    STORAGE_PORT="${storageBox.port}"
    STORAGE_USER="${storageBox.user}"
    SSH_KEY="${storageBox.sshKey}"
    BORG_REPO_BASE="ssh://$STORAGE_USER@$STORAGE_HOST:$STORAGE_PORT/./backups"

    # Directory mappings
    declare -A BACKUP_DIRS=(
      ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (k: v: "[\"${k}\"]=\"${v}\"") backupDirs)}
    )

    # Set up SSH and Borg environment
    export BORG_RSH="ssh -i $SSH_KEY -p $STORAGE_PORT -o StrictHostKeyChecking=no"
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    
    # Set up Borg passphrase
    BORG_PASSPHRASE_FILE="$HOME/.config/borg/passphrase"
    if [ -f "$BORG_PASSPHRASE_FILE" ]; then
      export BORG_PASSPHRASE=$(cat "$BORG_PASSPHRASE_FILE")
    else
      echo "Warning: Borg passphrase file not found at $BORG_PASSPHRASE_FILE"
      echo "Please run borg-setup.sh to generate it or create it manually"
    fi

    usage() {
      echo "Usage: $0 <command> <directory-key> [options]"
      echo ""
      echo "Commands:"
      echo "  init                     Initialize repositories"
      echo "  backup <dir-key>         Create backup of directory"
      echo "  list <dir-key>           List archives in repository"
      echo "  info <dir-key> [archive] Show repository or archive info"
      echo "  mount <dir-key> <path>   Mount repository to path"
      echo "  extract <dir-key> <archive> <path> Extract archive to path"
      echo "  prune <dir-key>          Prune old archives"
      echo ""
      echo "Available directory keys:"
      for key in "''${!BACKUP_DIRS[@]}"; do
        echo "  $key -> ''${BACKUP_DIRS[$key]}"
      done
      echo ""
      echo "Examples:"
      echo "  $0 init"
      echo "  $0 backup documents"
      echo "  $0 list documents"
      echo "  $0 info documents"
      echo "  $0 mount documents /tmp/backup-mount"
    }

    if [ $# -lt 1 ]; then
      usage
      exit 1
    fi

    COMMAND="$1"
    shift 1

    # Handle init command differently (no DIR_KEY needed)
    if [ "$COMMAND" != "init" ]; then
      if [ $# -lt 1 ]; then
        usage
        exit 1
      fi
      
      DIR_KEY="$1"
      shift 1

      # Validate directory key
      if [ -z "''${BACKUP_DIRS[$DIR_KEY]:-}" ]; then
        echo "Error: Unknown directory key '$DIR_KEY'"
        echo "Available keys: ''${!BACKUP_DIRS[*]}"
        exit 1
      fi

      SOURCE_DIR="''${BACKUP_DIRS[$DIR_KEY]}"
      REPO_URL="$BORG_REPO_BASE/$DIR_KEY"
      ARCHIVE_NAME="$DIR_KEY-$(date +%Y%m%d-%H%M%S)"

      # Expand tilde in source directory
      SOURCE_DIR_EXPANDED=$(eval echo "$SOURCE_DIR")
    fi

    case "$COMMAND" in
      init)
        echo "Checking and initializing all missing repositories..."
        for key in "''${!BACKUP_DIRS[@]}"; do
          repo_url="$BORG_REPO_BASE/$key"
          echo "Checking repository for $key..."
          if ${pkgs.borgbackup}/bin/borg info --remote-path=borg "$repo_url" &>/dev/null; then
            echo "  Repository for $key already exists"
          else
            echo "  Initializing repository for $key..."
            ${pkgs.borgbackup}/bin/borg init --encryption repokey-blake2 --remote-path=borg "$repo_url"
            echo "  Repository for $key initialized successfully"
          fi
        done
        echo "All repositories checked and initialized"
        ;;
      backup)
        echo "Creating backup of $DIR_KEY ($SOURCE_DIR_EXPANDED)..."
        ${pkgs.retry}/bin/retry -t 3 -d 30 ${pkgs.borgbackup}/bin/borg create \
          --verbose \
          --progress \
          --stats \
          --show-rc \
          --compression lz4 \
          --exclude-caches \
          --exclude '*.pyc' \
          --exclude '*.tmp' \
          --exclude '*/.git' \
          --exclude '*/node_modules' \
          --exclude '*/.cache' \
          --exclude '*/.DS_Store' \
          --remote-path=borg \
          "$REPO_URL::$ARCHIVE_NAME" \
          "$SOURCE_DIR_EXPANDED"
        ;;
      list)
        echo "Listing archives for $DIR_KEY..."
        ${pkgs.borgbackup}/bin/borg list --remote-path=borg "$REPO_URL"
        ;;
      info)
        if [ $# -gt 0 ]; then
          ARCHIVE="$1"
          echo "Archive info for $DIR_KEY::$ARCHIVE..."
          ${pkgs.borgbackup}/bin/borg info --remote-path=borg "$REPO_URL::$ARCHIVE"
        else
          echo "Repository info for $DIR_KEY..."
          ${pkgs.borgbackup}/bin/borg info --remote-path=borg "$REPO_URL"
        fi
        ;;
      mount)
        if [ $# -lt 1 ]; then
          echo "Error: mount requires a mount path"
          exit 1
        fi
        MOUNT_PATH="$1"
        echo "Mounting $DIR_KEY repository to $MOUNT_PATH..."
        ${pkgs.borgbackup}/bin/borg mount --remote-path=borg "$REPO_URL" "$MOUNT_PATH"
        ;;
      extract)
        if [ $# -lt 2 ]; then
          echo "Error: extract requires archive name and extraction path"
          exit 1
        fi
        ARCHIVE="$1"
        EXTRACT_PATH="$2"
        echo "Extracting $DIR_KEY::$ARCHIVE to $EXTRACT_PATH..."
        cd "$EXTRACT_PATH"
        ${pkgs.borgbackup}/bin/borg extract --remote-path=borg "$REPO_URL::$ARCHIVE"
        ;;
      prune)
        echo "Pruning old archives for $DIR_KEY..."
        ${pkgs.borgbackup}/bin/borg prune \
          --remote-path=borg \
          --list \
          --stats \
          --show-rc \
          --keep-daily=7 \
          --keep-weekly=4 \
          --keep-monthly=6 \
          "$REPO_URL"
        ;;
      *)
        echo "Error: Unknown command '$COMMAND'"
        usage
        exit 1
        ;;
    esac
  '';

  # SSH key setup script
  sshKeySetup = pkgs.writeShellScript "borg-setup" ''
    set -euo pipefail

    SSH_KEY="${storageBox.sshKey}"
    SSH_DIR="$(dirname "$SSH_KEY")"
    PUB_KEY="$SSH_KEY.pub"

    # Create SSH directory if it doesn't exist
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Check if key already exists
    if [ -f "$SSH_KEY" ]; then
      echo "SSH key already exists at $SSH_KEY"
      echo "Public key:"
      cat "$PUB_KEY" 2>/dev/null || echo "Public key not found"
      exit 0
    fi

    echo "Generating SSH key for Hetzner storage box..."
    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "$SSH_KEY" -C "hetzner-backup-$(hostname)"

    chmod 600 "$SSH_KEY"
    chmod 644 "$PUB_KEY"

    echo ""
    echo "SSH key generated successfully!"
    echo "Public key:"
    cat "$PUB_KEY"
    echo ""
    echo "Installing SSH key on Hetzner storage box..."
    
    # Use ssh-copy-id to install the key
    if ${pkgs.openssh}/bin/ssh-copy-id -i "$SSH_KEY" -p ${storageBox.port} ${storageBox.user}@${storageBox.host}; then
      echo "SSH key successfully installed on storage box!"
      echo ""
      echo "Testing SSH connection..."
      if ${pkgs.openssh}/bin/ssh -i "$SSH_KEY" -p ${storageBox.port} -o ConnectTimeout=10 ${storageBox.user}@${storageBox.host} "echo 'SSH connection successful'"; then
        echo "SSH connection test successful!"
      else
        echo "SSH connection test failed - this is normal for borg-only access"
      fi
    else
      echo "Failed to install SSH key automatically."
      echo "You can install it manually using one of these methods:"
      echo ""
      echo "Method 1 (automatic install):"
      echo "cat $PUB_KEY | ssh -p${storageBox.port} ${storageBox.user}@${storageBox.host} install-ssh-key"
      echo ""
      echo "Method 2 (manual):"
      echo "ssh -p ${storageBox.port} ${storageBox.user}@${storageBox.host} mkdir .ssh"
      echo "scp -P ${storageBox.port} $PUB_KEY ${storageBox.user}@${storageBox.host}:.ssh/authorized_keys"
    fi
  '';

in
{
  # Install the borg wrapper script
  home.packages = [
    (pkgs.stdenv.mkDerivation {
      name = "borg-backup-scripts";
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        cp ${borgWrapper} $out/bin/borg-backup
        cp ${sshKeySetup} $out/bin/borg-setup
        chmod +x $out/bin/*
      '';
    })
  ];

  # Add convenient aliases
  home.shellAliases = {
    borg-backup = "borg-backup";
    borg-setup = "borg-setup";
  };

  # SSH agent configuration for automatic key loading (Linux only)
  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
  };

  # SSH configuration for Hetzner storage box
  # programs.ssh = {
  #   enable = true;
  #   matchBlocks."${storageBox.host}" = {
  #     hostname = storageBox.host;
  #     port = lib.toInt storageBox.port;
  #     user = storageBox.user;
  #     identityFile = storageBox.sshKey;
  #     extraOptions = {
  #       AddKeysToAgent = "yes";
  #       IgnoreUnknown = "UseKeychain";
  #       UseKeychain = "yes";
  #       StrictHostKeyChecking = "no";
  #     };
  #   };
  # };

  # Systemd user service for automated backups (Linux only)
  systemd.user.services = lib.mkIf pkgs.stdenv.isLinux (
    lib.mapAttrs
      (dirKey: dirPath: {
        description = "Automated borg backup for ${dirKey}";
        script = "${borgWrapper} backup ${dirKey}";
        path = [ pkgs.borgbackup pkgs.openssh pkgs.retry ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "300";
          StartLimitBurst = "3";
          StartLimitIntervalSec = "3600";
        };
        environment = {
          HOME = config.home.homeDirectory;
        };
      })
      backupDirs
  );

  # Systemd user timers for scheduled backups (Linux only)
  systemd.user.timers = lib.mkIf pkgs.stdenv.isLinux (
    lib.mapAttrs
      (dirKey: dirPath: {
        description = "Daily backup timer for ${dirKey}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      })
      backupDirs
  );

  # macOS launchd agents for scheduled backups
  launchd.agents = lib.mkIf pkgs.stdenv.isDarwin (
    lib.mapAttrs
      (dirKey: dirPath: {
        enable = true;
        config = {
          ProgramArguments = [ "${borgWrapper}" "backup" dirKey ];
          StartCalendarInterval = [{
            Hour = 2;
            Minute = 0;
          }];
          StandardErrorPath = "${config.home.homeDirectory}/.local/var/log/borg-backup-${dirKey}.log";
          StandardOutPath = "${config.home.homeDirectory}/.local/var/log/borg-backup-${dirKey}.log";
          KeepAlive = {
            SuccessfulExit = false;
          };
          ThrottleInterval = 300;
        };
      })
      backupDirs
  );
}
