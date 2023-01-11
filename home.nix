{ config, pkgs, lib, ... }:

{
  home.stateVersion = "22.11";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  programs.zsh = {
    enable = true;
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
      PASSWORD_STORE_DIR = "/some/directory";
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
    # Some basics
    coreutils
    curl
    wget
    fzf
    fd
    gnupg
    tmux

    # Dev stuff
    jq
    nodejs

    yarn
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}
