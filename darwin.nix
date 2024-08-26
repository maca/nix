{ pkgs, lib, ... }:
{
  # hammerspoon = pkgs.callPackage ./apps/hammerspoon.nix { };

  nix.configureBuildUsers = true;

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
  services.nix-daemon.enable = true;
  users.users.maca.home = "/Users/maca";


  environment.systemPackages = with pkgs; [
    pkgs.emacs
    pkgs.pam-reattach
    pkgs.shared-mime-info
    terminal-notifier
  ];


  programs.nix-index.enable = true;


  # Fonts
  fonts.packages = with pkgs; [
    recursive
    (nerdfonts.override { fonts = [ "JetBrainsMono" "Inconsolata" ]; })
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Homebrew packages
  homebrew.enable = true;
  homebrew.casks = [
    "eloston-chromium"
    "rawtherapee"
    "kitty"
    "inkscape"
    "xnviewmp"
    "pgp-suite"
  ];
}
