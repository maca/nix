{ pkgs, lib, ... }:
{
  nix.configureBuildUsers = true;


  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';


  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;
  };


  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;


  environment.systemPackages = with pkgs; [
    kitty
    terminal-notifier
  ];


  programs.nix-index.enable = true;


  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
     recursive
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
   ];


  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;


  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;
}
