{ pkgs, lib, ... }:

{
  home.stateVersion = "24.05";

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
        "ui.cursor.match" = { fg = "dark_gray"; bg = "gray"; };
        "diagnostic.error" = { underline = { style = "curl"; }; };
      };

      light = {
        inherits = "ayu_light";
        comment = { fg = "gray"; };
        "ui.cursor" = { fg = "dark_gray"; bg = "blue"; };
        "ui.cursor.primary" = { fg = "dark_gray"; bg = "orange"; };
        "ui.cursor.match" = { fg = "dark_gray"; bg = "gray"; };
        "diagnostic.error" = { underline = { style = "curl"; }; };
      };
    };

    languages = {
      language = [
        {
          name = "elm";
          formatter = { command = "elm-format"; args = [ "--stdin" ]; };
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = { command = "dprint"; args = [ "fmt" "--stdin" "md" ]; };

        }
        {
          name = "nix";
          auto-format = true;
          formatter = { command = "nixpkgs-fmt"; args = [ ]; };
        }
      ];
    };
  };


  # programs.emacs = {
  #   enable = true;
  #   package = pkgs.emacsWithPackagesFromUsePackage {
  #     config = "/Users/maca/nix/emacs.el";
  #     defaultInitFile = true;
  #     package = pkgs.emacs-pgtk;
  #     alwaysTangle = true;
  #   };
  # };


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
    EDITOR = "hx";
    LOCALE = "LANG=en_US.UTF-8";
  };


  programs.zsh = {
    enable = true;
    shellAliases = {
      # emacs = "${pkgs.emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";
      ls = "ls --color";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "fzf" "ssh-agent" "pass" "emoji" "transfer" ];
      extraConfig = "zstyle :omz:plugins:ssh-agent identities id_rsa";
    };
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
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
    initExtra = ''
      PATH="$(${pkgs.yarn}/bin/yarn global bin):$PATH"
    '';
    defaultKeymap = "viins";
    profileExtra = '' 
      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"    
      fi

      export PATH
    '';
  };


  programs.ssh =
    {
      enable = true;
      matchBlocks = {
        router = {
          hostname = "192.168.8.1";
          user = "root";
        };
      };
    };


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

      # Set window notifications
      setw -g monitor-activity on
      set -g visual-activity on
      set -s set-clipboard on

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
      pull.rebase = "true";

      init = { defaultBranch = "main"; };
      pager.difftool = true;

      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
      github.user = "maca";
      gitlab.user = "maca";

      commit.gpgsign = true;
      user.signingkey = "6BBF61F857AAD28F42320FE60973371CAB06A408";

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
    # ".emacs.el".source = "/Users/maca/nix/emacs.el";
    # "emacs/ligature.el".source = "/Users/maca/nix/emacs/ligature.el";
    # "emacs/ivy-taskrunner.el".source = "/Users/maca/nix/emacs/ivy-taskrunner.el";
    ".config/kitty/kitty.conf".text = ''
      font_family Inconsolata
      font_size 15

      background_opacity 0.8
      background_blur 16

      window_margin_width 4
      single_window_margin_width 0
      active_border_color   #d0d0d0
      inactive_border_color #202020

      hide_window_decorations titlebar-only

      tab_bar_style powerline
      tab_powerline_style slanted

      confirm_os_window_close 0

      background            #202020
      foreground            #d0d0d0
      cursor                #d0d0d0
      selection_background  #303030
      color0                #151515
      color8                #505050
      color1                #ac4142
      color9                #ac4142
      color2                #7e8d50
      color10               #7e8d50
      color3                #e5b566
      color11               #e5b566
      color4                #6c99ba
      color12               #6c99ba
      color5                #9e4e85
      color13               #9e4e85
      color6                #7dd5cf
      color14               #7dd5cf
      color7                #d0d0d0
      color15               #f5f5f5
      selection_foreground  #202020

      enable_audio_bell no
      bell_on_tab "🔔 "

      map f1 new_window_with_cwd

      detect_urls yes

      macos_option_as_alt no
      macos_option_as_alt left
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
    elmPackages.elm-language-server
    elmPackages.elm-review
    # elmPackages.elm-format
    # elmPackages.elm-analyse
    # elmPackages.elm-verify-examples

    redocly

    marksman
    markdown-oxide
    dprint
    pandoc

    # JS stuff
    # nodejs
    nodejs_22
    yarn
    nodePackages.typescript-language-server
    yarn2nix
    node2nix

    nodePackages.ts-node

    # BEAM
    elixir
    gleam

    # Haskell
    # stack

    # ETC
    tesseract4 # OCR
    ghostscript # Postcript interpreter
    yt-dlp # Youtube/video downloader
    zbar # qrcode reader
    retry
    httrack
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}

