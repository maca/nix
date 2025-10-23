{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [
      epkgs.magit
      epkgs.melpaPackages.helix
      epkgs.nongnuPackages.multiple-cursors
    ];
  };

  home.file.".emacs.d/init.el".text = ''
    ;; Basic emacs configuration
    (setq inhibit-startup-message t)
    (setq ring-bell-function 'ignore)
    (column-number-mode 1)

    ;; Setup helix-mode with multiple cursors
    (require 'multiple-cursors)
    (require 'helix)

    ;; Enable multiple cursors support for helix
    (helix-multiple-cursors-setup)

    ;; Enable relative line numbers in normal mode, absolute in insert mode
    (add-hook 'helix-normal-mode-hook (lambda () (setq display-line-numbers 'relative)))
    (add-hook 'helix-insert-mode-hook (lambda () (setq display-line-numbers t)))

    ;; Enable helix-mode globally
    (helix-mode)
  '';
}