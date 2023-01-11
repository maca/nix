{ config, pkgs, lib, callPackage, ... }:
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


  programs.zsh = {
    enable = true;
  };


  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];


  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;


  environment.systemPackages = with pkgs; [
    terminal-notifier

    (emacsWithPackagesFromUsePackage {
      config = "/Users/macarioortega/nix-home/emacs.el";
      defaultInitFile = true;
      package = pkgs.emacsGit;
      alwaysEnsure = true;
      alwaysTangle = true;
    })
  ];


  programs.nix-index.enable = true;


  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
     recursive
     (nerdfonts.override { fonts = [ "JetBrainsMono" "Inconsolata" ]; })
   ];


  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;


  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;
}
