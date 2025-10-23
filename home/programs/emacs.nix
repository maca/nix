{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29;
    extraConfig = ''
      ;; Basic emacs configuration
      (setq inhibit-startup-message t)
      (setq ring-bell-function 'ignore)
      (global-display-line-numbers-mode 1)
      (column-number-mode 1)
      
      ;; Enable helix-mode
      (require 'helix)
      (helix-mode 1)
    '';
    extraPackages = epkgs: with epkgs.melpaPackages; [
      epkgs.magit
      helix
    ];
  };
}