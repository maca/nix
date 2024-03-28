{ pkgs, lib, ... }:

{
  home.stateVersion = "23.05";

  programs.helix = {
    enable = true;

    settings = {
      theme = "dark";
      editor = {
        line-number = "relative";
        idle-timeout = 400;
        rulers = [ 80 90 ];
        indent-guides = {
          render = true;
          character = "|";
        };
        color-modes = true;
      };
      keys = {
        normal = {
          space.t.d = ":theme dark";
          space.t.l = ":theme light";
          space.c.f = ":format";
          space.c.o = ":sh gh repo view --web";
        };
      };
    };
    themes = {
      dark = {
        inherits = "ayu_mirage";
        comment = { fg = "gray"; };
        "ui.cursor" = { fg = "dark_gray"; bg = "blue"; };
        "ui.cursor.primary" = { fg = "dark_gray"; bg = "orange"; };
        "ui.cursor.match" = { fg = "dark_gray"; bg = "blue"; };
        "diagnostic.error" = { underline = { style = "curl"; }; };
      };
      light = {
        inherits = "ayu_light";
        comment = { fg = "gray"; };
        "ui.cursor" = { fg = "dark_gray"; bg = "blue"; };
        "ui.cursor.primary" = { fg = "dark_gray"; bg = "orange"; };
        "ui.cursor.match" = { fg = "dark_gray"; bg = "blue"; };
        "diagnostic.error" = { underline = { style = "curl"; }; };
      };
    };
  };


  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithPackagesFromUsePackage {
      config = "/Users/maca/nix/emacs.el";
      defaultInitFile = true;
      package = pkgs.emacsPgtk;
      alwaysTangle = true;
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


  home.sessionVariables = {
    EDITOR = "vim";
  };


  programs.zsh = {
    enable = true;
    shellAliases = {
      emacs = "${pkgs.emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";
      ls = "ls --color";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "fzf" "ssh-agent" "pass" "emoji" "transfer" ];
    };
    zplug = {
      enable = true;
      plugins = [
        {
          name = "wfxr/forgit";
          tags = [ ];
        }
        {
          name = "g-plane/zsh-yarn-autocompletions";
          tags = [ ''hook-build:"./zplug.zsh", defer:2'' ];
        }
      ];
      zplugHome = "/Users/maca/.config/zplug";
    };
    defaultKeymap = "viins";
    profileExtra = '' 
      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"    
      fi

      # path=('/Users/maca/.cargo/bin' $path)
      # export to sub-processes (make it inherited by child processes)
      export PATH

      bindkey "\e" vi-cmd-mode
    '';
  };


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
      setw -g automatic-rename on

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
      bind c new-window -c "#{pane_current_path}"
          bind s split-window -v -c "#{pane_current_path}"
          bind v split-window -h -c "#{pane_current_path}"
          bind S list-sessions
          '';
  };


  programs.git = {
    enable = true;
    userName = "Macario Ortega";
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

    ignores = [ "*.swp" ];
    extraConfig = {
      pull.ff = "only";
      init = { defaultBranch = "main"; };
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
      PASSWORD_STORE_DIR = "/Users/maca/.password-store";
      PASSWORD_STORE_CLIP_TIME = "60";
    };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };


  home.file = {
    ".emacs.el".source = "/Users/maca/nix/emacs.el";
    "emacs/ligature.el".source = "/Users/maca/nix/emacs/ligature.el";
    "emacs/ivy-taskrunner.el".source = "/Users/maca/nix/emacs/ivy-taskrunner.el";
    ".config/helix/languages.toml".text = ''
      [[language]]
      name = "elm"
      formatter = { command = "elm-format", args = ["--stdin"] }

      [[language]]
      name = "nix"
      auto-format = true
      formatter = { command = "nixpkgs-fmt", args = [] }
    '';
  };


  home.packages = with pkgs; [
    coreutils
    curl
    wget
    gnupg
    fzf
    fd
    silver-searcher
    difftastic
    delta
    lazygit
    gitui
    gh
    nixpkgs-fmt
    nil
    zplug
    # cargo
    cloc
    ssh-copy-id

    heroku

    shared-mime-info
    (ruby.withPackages (ps: with ps; [ nokogiri pry pg rails minitest ]))
    ffmpeg
    imagemagick
    graphviz
    vimv


    pgcli
    jq
    yq
    postgresql

    vimv

    stack

    podman
    qemu
    buildah
    docker-compose

    # Elm stuff
    elmPackages.elm
    elmPackages.elm-doc-preview
    elmPackages.elm-live
    elmPackages.elm-test
    elmPackages.elm-format
    elmPackages.elm-analyse
    elmPackages.elm-language-server
    # extraNodePackages.elm-watch


    # JS stuff
    # nodejs
    nodejs_20
    yarn
    nodePackages.typescript-language-server
    yarn2nix
    node2nix

    nodePackages.ts-node

    # Elixir
    elixir_1_16
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}

