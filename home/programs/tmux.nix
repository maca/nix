{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    newSession = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    terminal = "xterm-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    aggressiveResize = true;
    sensibleOnTop = false;
    customPaneNavigationAndResize = true;
    resizeAmount = 3;
    secureSocket = true;
    extraConfig = '' 
      setw -g automatic-rename on
      set -g default-command "$SHELL"
      setw -g monitor-activity on
      set -g visual-activity on
      set -s set-clipboard on
      bind-key -r Space select-pane -t :.+
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r Left resize-pane -L 3
      bind -r Down resize-pane -D 3
      bind -r Up resize-pane -U 3
      bind -r Right resize-pane -R 3
      bind-key -r Tab rotate-window
      bind-key -r J next-window
      bind-key -r K previous-window
      bind-key a last-window
      unbind %
      bind c new-window -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind S list-sessions
    '';
  };
}
