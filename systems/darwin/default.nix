{ pkgs, lib, userConfig, ... }:
{
  # Enable experimental nix command and flakes
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.bash.enable = true;
  programs.zsh.enable = true;

  environment.shells = with pkgs; [ bashInteractive zsh ];
  environment.pathsToLink = [ "/share/zsh" ];

  # Set primary user dynamically
  system.primaryUser = userConfig.username;

  # Base system packages
  environment.systemPackages = with pkgs; [
    pam-reattach
    shared-mime-info
    terminal-notifier
    docker
    colima
  ];

  programs.nix-index.enable = true;

  # Common fonts
  fonts.packages = [
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
  ];

  system.stateVersion = 5;
  ids.gids.nixbld = 30000;

  # Keyboard settings
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Homebrew configuration
  homebrew.enable = true;
  homebrew.casks = [
    "eloston-chromium"
    "rawtherapee"
    "kitty"
    "inkscape"
    "xnviewmp"
    "gimp"
    "rsyncui"
  ];
}
