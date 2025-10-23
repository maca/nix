{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [
      epkgs.magit
      epkgs.melpaPackages.helix
      epkgs.nongnuPackages.multiple-cursors
      epkgs.melpaPackages.solarized-theme
    ];
  };

  home.file.".emacs.d/init.el".text = ''
    ;;; Font configuration
    (set-face-attribute 'default nil
                        :family "Inconsolata Nerd Font"
                        :height 240
                        :weight 'normal)

    ;;; Basic emacs configuration
    (setq inhibit-startup-message t)
    (setq initial-scratch-message nil)

    ;; Disable menu bar (especially useful in terminal mode)
    (menu-bar-mode -1)

    ;;; Window configuration
    (add-to-list 'default-frame-alist '(fullscreen . maximized))

    ;;; Theme configuration
    (require 'solarized-theme)
    (load-theme 'solarized-dark t)

    ;;; Git configuration
    (require 'magit)

    ;;; Helix-mode with multiple cursors
    (require 'multiple-cursors)
    (require 'helix)

    ;; Enable multiple cursors support for helix
    (helix-multiple-cursors-setup)

    ;; Enable jj as escape for terminal mode (where ESC doesn't bind properly)
    (helix-jj-setup 0.2)

    ;; Enable relative line numbers in normal mode, absolute in insert mode
    (add-hook 'helix-normal-mode-hook (lambda () (setq display-line-numbers 'relative)))
    (add-hook 'helix-insert-mode-hook (lambda () (setq display-line-numbers t)))

    ;; Enable helix-mode globally - use after-init-hook to ensure it activates properly
    (add-hook 'after-init-hook 'helix-mode)
    (global-set-key (kbd "C-z") 'helix-mode)
  '';
}
