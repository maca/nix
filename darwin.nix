{ pkgs, lib, ... }:
{
  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
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

  # Auto upgrade nix package and the daemon service.
  users.users.maca.home = "/Users/maca";



  environment.systemPackages = with pkgs; [
    pkgs.pam-reattach
    pkgs.shared-mime-info
    terminal-notifier
    ##-> Docker stuff
    docker
    colima
    ##<- Docker stuff
  ];

  programs.nix-index.enable = true;


  fonts.packages = [
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
  ];


  system.stateVersion = 5;
  ids.gids.nixbld = 30000;

  system.primaryUser = "maca";
  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Homebrew packages
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
