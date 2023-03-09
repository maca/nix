{ config, pkgs, lib,  ... }:

let
  extraNodePackages = import ./node/default.nix {};
  helix = (pkgs.callPackage ./helix.nix { });
in
{
  home.stateVersion = "23.05";


  home.sessionVariables = {
    EDITOR = "hx";
  };
 

  programs.helix = {
    enable = true;
    package = helix;
    settings = {
      theme = "ayu_mirage";
      editor = {
        line-number = "relative";
        idle-timeout = 400;
        rulers = [ 80 90 ];
        indent-guides = {
          render = true;
          character = "|";
        };
      }; 
      keys = {
        normal = {
          space.t.d = ":theme ayu_mirage";
          space.t.l = ":theme ayu_light";
          space.c.f = ":format";
          space.c.o = ":sh gh repo view --web";
          D = "kill_to_line_end";
        };
      };
    }; 
  };


  programs.browserpass.enable = true;

  
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
      package = pkgs.emacsPgtk;
      alwaysTangle = true;
    };
  };


  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      right_format = "$time";
      time = {
        disabled = false;
        style = "bright-black";
        format = "[$time]($style)";
      };
    };
  };


  programs.zsh = {
    enable = true;
    shellAliases = {
      emacs = "${pkgs.emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "fzf" "ssh-agent" "pass" "emoji" "transfer" ];
    }; 
    sessionVariables = {
      EDITOR = "hx";
    };
    defaultKeymap = "viins";
    profileExtra = '' 
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"    
    fi

    path=('/Users/macarioortega/.cargo/bin' $path)
    # export to sub-processes (make it inherited by child processes)
    export PATH
    '';
  };


  # programs.zplug = {
  #   enable = true;
  #   plugins = [ "forgit" ];
  # };


  programs.tmux = {
    enable = true;
    shortcut = "a";
    newSession = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    shell = "/bin/zsh";
    secureSocket = true;
    extraConfig = '' 
      set-option -g default-shell /bin/zsh

      # default terminal
      set -g default-terminal "xterm-256color"
      setw -g aggressive-resize on

      # Set window notifications
      setw -g monitor-activity on
      set -g visual-activity on

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
    '';
  };


  programs.git = {
    enable = true;
    userName  = "Macario Ortega";
    userEmail = "maca@aelita.io";

    aliases = {
      h = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --abbrev-commit --date=short";
      ha = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --all --abbrev-commit --date=short";
      ff = "!branch=$(git symbolic-ref HEAD | cut -d '/' -f 3) && git merge --ff-only $\{1\:-$(git config --get branch.$branch.remote)/$( git config --get branch.$branch.merge | cut -d '/' -f 3)\}";
      dm = "branch --merged | grep -v \* | xargs git branch -D";

      ignore = "update-index --assume-unchanged";
      unignore = "update-index --no-assume-unchanged";
      d = "difftool";
    };

    ignores = ["*.swp"];
    extraConfig = {
      pull.ff = "only";
      init = {defaultBranch = "main";};
      pager.difftool = true;

      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
      github.user = "maca";
      gitlab.user = "maca";

      core.excludesfile = "~/.gitignore";
    };
  };


  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "/Users/macarioortega/.password-store";
      PASSWORD_STORE_CLIP_TIME = "60";
    };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };


  home.file = {
    ".emacs.el".source = "/Users/macarioortega/nix-home/emacs.el";
    "emacs/ligature.el".source = "/Users/macarioortega/nix-home/emacs/ligature.el";
    "emacs/ivy-taskrunner.el".source = "/Users/macarioortega/nix-home/emacs/ivy-taskrunner.el";
    ".config/helix/runtime/elm/textobjects.scm".source = "/Users/macarioortega/nix-home/helix/runtime/queries/elm/textobjects.scm";
    ".config/helix/languages.toml".text = ''
      [[language]]
      name = "elm"
      formatter = { command = "elm-format", args = ["--stdin"] }
      '';
  };


  home.packages = with pkgs; [
    coreutils
    curl wget gnupg
    fzf fd silver-searcher
    difftastic lazygit gitui gh
    nil # nix language server
    zplug
    cargo

    pgcli
    jq yq

    # JS stuff
    nodejs
    yarn

    stack

    # Elm stuff
    elmPackages.elm
    elmPackages.elm-language-server

    extraNodePackages.elm-test
    extraNodePackages.elm-format
    extraNodePackages.elm-analyse
    extraNodePackages.elm-watch
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}
