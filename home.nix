{ config, pkgs, lib,  ... }:

let
  extraNodePackages = import ./node/default.nix {};

  emacs = pkgs.emacsPgtk.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        # Fix OS window role (needed for window managers like yabai)
        (pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
          sha256 = "0c41rgpi19vr9ai740g09lka3nkjk48ppqyqdnncjrkfgvm2710z";
        })

        # Use poll instead of select to get file descriptors
        (pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
          sha256 = "0j26n6yma4n5wh4klikza6bjnzrmz6zihgcsdx36pn3vbfnaqbh5";
        })

        # Enable rounded window with no decoration
        (pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
          sha256 = "111i0r3ahs0f52z15aaa3chlq7ardqnzpwp8r57kfsmnmg6c2nhf";
        })

        # Make Emacs aware of OS-level light/dark mode
        (pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
          sha256 = "14ndp2fqqc95s70fwhpxq58y8qqj4gzvvffp77snm2xk76c1bvnn";
        })
      ];
  });

in
{
  home.stateVersion = "22.11";


  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };


  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };


  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithPackagesFromUsePackage {
      config = "/Users/macarioortega/nix-home/emacs.el";
      defaultInitFile = true;
      package = emacs;
      # alwaysEnsure = true;
      alwaysTangle = true;
    };
  };


  programs.zsh = {
    enable = true;
    shellAliases = {
      emacs = "${pkgs.emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";
    };
  };


  programs.git = {
    enable = true;
    userName  = "Macario Ortega";
    userEmail = "maca@aelita.io";

    aliases = {
      h = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --abbrev-commit --date=short";
      ha = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --all --abbrev-commit --date=short";
      ff = "!branch=$(git symbolic-ref HEAD | cut -d '/' -f 3) && git merge --ff-only $\{1\:-$(git config --get branch.$branch.remote)/$( git config --get branch.$branch.merge | cut -d '/' -f 3)\}";

      ignore = "update-index --assume-unchanged";
      unignore = "update-index --no-assume-unchanged";
    };

    ignores = ["*.swp"];
    extraConfig = {
      pull.ff = "only";
    };
  };


  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "/Users/macarioortega/.password-store";
      PASSWORD_STORE_CLIP_TIME = "60";
    };
  };


  home.file = {
    ".emacs.el".source = "/Users/macarioortega/nix-home/emacs.el";
    "emacs/ligature.el".source = "/Users/macarioortega/nix-home/emacs/ligature.el";
    ".config/tmux/tmux.conf".text = ''
      new-session

      # instructs tmux to expect UTF-8 sequences
      setw -g utf8 on
      # default terminal
      set -g default-terminal "xterm-256color"
      setw -g aggressive-resize on

      # tmux key
      set-option -g prefix C-a
      # vi bindings
      setw -g mode-keys vi
      # Set window notifications
      setw -g monitor-activity on
      set -g visual-activity on
      set -g visual-content on
      # prevent automatic renaming
      setw -g automatic-rename on

      # cycle through panes
      bind-key -r Space select-pane -t :.+
      # move around panels
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      # resize panels
      bind -r Left resize-pane -L 3
      bind -r Down resize-pane -D 3
      bind -r Up resize-pane -U 3
      bind -r Right resize-pane -R 3

      # move through windows
      bind-key -r Tab rotate-window
      bind-key -r J next-window
      bind-key -r K previous-window
      # last window
      bind-key a last-window

      # splitting windows
      unbind % # Remove default binding since we’re replacing
      bind s split-window -v
      bind v split-window -h
      bind S list-sessions

      # inteact with system clipboard
      unbind p
      bind p run "xclip -o | tmux load-buffer - ; tmux paste-buffer"
      bind y run-shell "tmux show-buffer | xclip -sel clip -i" \; display-message "Copied tmux buffer to system clipboard"

      bind -n WheelUpPane copy-mode

      # Toggle mouse on with ^B m
      bind m \
        set -g mouse on \;\
        set -g mouse-utf8 on \;\
        display 'Mouse: ON'

      # Toggle mouse off with ^B M
      bind M \
        set -g mouse off \;\
        set -g mouse-utf8 off \;\
        display 'Mouse: OFF'

      set -g mouse off
      set -g mouse-utf8 off


      # Set status bar
      set -g status-bg green
      set-option -g status-utf8 on
      set-window-option -g window-status-current-bg black
      set-window-option -g window-status-current-fg green
      set -g status-right '#[fg=green]#(acpi -V | head -n 1) #[fg=cyan]%a %d %b, %H:%M#[default]'
      set -g status-interval 5
      set -g status-right-length 90
      set-option -g pane-active-border-fg red
      set -g status-bg black
      set -g status-fg white
      set -g status-left ‘#[fg=green]#H’

      set -g default-path "$PWD"

      set-option -g history-limit 100000

      # Fix emacs delay
      set-option -sg escape-time 0
    '';
  };

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    gnupg
    tmux
    fzf
    fd
    silver-searcher

    jq

    nodejs
    yarn

    elmPackages.elm
    extraNodePackages.elm-test
    extraNodePackages.elm-format
    extraNodePackages.elm-analyse
    extraNodePackages.elm-watch
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}
