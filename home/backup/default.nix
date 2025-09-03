{ pkgs, lib, ... }:

{
  imports = [
    ./documents.nix
    ./photos.nix
  ];
  home.packages = with pkgs; [
    borgbackup
    borgmatic
    python3Packages.llfuse
  ];


  # Create backup and borgbase script binaries
  home.file.".local/bin/backup" = {
    text = ''
      #!/bin/bash
      set -euo pipefail
      if [[ $# -eq 0 ]]; then
        echo "Usage: backup <config_name> [borgmatic_args...]"
        exit 1
      fi
      
      config_name="$1"
      shift
      borgmatic -c "$HOME/.config/borgmatic/$config_name.yaml" "$@"
    '';
    executable = true;
  };

  home.file.".local/bin/borgbase" = {
    text = ''
      #!/bin/bash
      set -euo pipefail
      if [[ $# -lt 2 ]]; then
        echo "Usage: borgbase <repo_name> <borg_command> [args...]"
        echo "Example: borgbase documents list"
        echo "Example: borgbase photos create backup-{now}"
        exit 1
      fi
      
      repo_name="$1"
      shift
      
      # Set the passcommand for this specific repo
      export BORG_PASSCOMMAND="sh -c 'pass borgbase.com/repos/$repo_name | head -n1 | tr -d \"\\n\"'"
      
      # If first argument doesn't contain a colon, prepend the repo path
      if [[ "$1" != *":"* ]]; then
        set -- "$1" "borgbase-$repo_name:./repo''${2:+::$2}" "''${@:3}"
      fi
      
      # Run borg with the modified arguments
      borg "$@"
    '';
    executable = true;
  };
}
