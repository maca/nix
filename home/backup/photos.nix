{ lib, ... }:

{
  home.file.".config/borgmatic/photos.yaml".text = lib.generators.toYAML { } {
    # Directories to backup (relative to working_directory)
    source_directories = [
      "Fotos"
      "Capture"
    ];

    # Remote repository configuration
    repositories = [
      {
        path = "ssh://borgbase-photos/./repo";
        label = "borgbase-backup";
        encryption = "repokey-blake2"; # Encryption method
      }
    ];

    encryption_passcommand = "sh -c 'pass borgbase.com/repos/photos | head -n1 | tr -d \"\\n\"'";

    # Base directory for relative paths
    working_directory = "/Volumes/Fast/Fotos";

    # Filesystem behavior
    one_file_system = true; # Don't cross mount points
    numeric_ids = false; # Store user/group names, not just IDs
    atime = false; # Don't store access times
    ctime = true; # Store change times
    birthtime = true; # Store creation times (macOS)
    read_special = false; # Don't backup special devices
    flags = true; # Store filesystem flags
    files_cache = "ctime,size,inode"; # Cache method for speed

    # Files to exclude from backup
    exclude_patterns = [ "*.DS_Store" ];

    # Advanced exclusions
    exclude_caches = true; # Skip directories with CACHEDIR.TAG
    exclude_nodump = false; # Include files with NODUMP flag

    # Error handling
    source_directories_must_exist = false; # Don't fail if source missing

    # Performance settings
    checkpoint_interval = 1800; # Checkpoint every 30 minutes
    compression = "zstd,3"; # Compression algorithm and level
    upload_rate_limit = 0; # No bandwidth limit
    retries = 0; # Don't retry failed operations
    retry_wait = 0; # No wait between retries
    lock_wait = 5; # Wait 5s for repository locks

    # Archive naming and behavior
    archive_name_format = "{hostname}-{now:%Y-%m-%dT%H:%M:%S}";
    relocated_repo_access_is_ok = false; # Error if repo moved
    unknown_unencrypted_repo_access_is_ok = false; # Error on unknown unencrypted repos

    # Retention policy - how many backups to keep
    keep_daily = 7; # Keep 7 daily backups
    keep_weekly = 4; # Keep 4 weekly backups
    keep_monthly = 6; # Keep 6 monthly backups

    # Integrity checks
    checks = [
      {
        name = "repository"; # Check repo consistency
        frequency = "2 weeks";
      }
      {
        name = "archives"; # Check archive consistency
        frequency = "1 month";
      }
    ];

    # Output and logging
    color = true; # Colorized output
    verbosity = 1; # Info level logging
    syslog_verbosity = -2; # No syslog
    log_file_verbosity = -2; # No log file
    monitoring_verbosity = 1; # Info for monitoring hooks
    log_json = false; # Text output, not JSON
    progress = true; # Show progress bars
    statistics = true; # Show backup statistics
    list_details = false; # Don't list individual files

    # Behavior settings
    default_actions = true; # Run create/prune/check when no args given
  };
}
