userConfig: { pkgs, lib, ... }:

{
  home.stateVersion = "25.05";

  # Import modular configurations
  imports = [
    ./programs
    ./shell
    ./backup
    (import ./git/default.nix { inherit userConfig; })
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    LOCALE = "LANG=en_US.UTF-8";
  };

  # All packages
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    curl
    wget
    gnupg
    shared-mime-info

    # Shell and CLI tools
    fzf
    fd
    watch
    silver-searcher
    jq
    yq
    vimv
    cloc
    retry

    # Git and version control
    gh
    lazygit
    difftastic
    delta
    zsh-forgit

    # SSH tools
    ssh-copy-id

    # Nix tools
    nixpkgs-fmt
    nil

    # Shell
    zplug

    # Development environments and languages
    # Haskell
    stack

    # Ruby
    ruby_3_3

    # Elm
    elmPackages.elm
    elmPackages.elm-doc-preview
    elmPackages.elm-live
    elmPackages.elm-test
    elmPackages.elm-language-server
    elmPackages.elm-review

    # Node.js and JavaScript
    nodejs_22
    yarn
    nodePackages.typescript-language-server
    nodePackages.ts-node
    yarn2nix
    node2nix
    sass
    eslint

    # Elixir
    elixir

    # Gleam
    gleam

    # Database
    postgresql
    pgcli

    # Web server
    nginx

    # Containers and virtualization
    podman
    qemu
    docker-compose

    # Documentation and markup
    marksman
    markdown-oxide
    dprint
    pandoc
    redocly
    mustache-go

    # Media tools
    ffmpeg
    imagemagick
    graphviz
    tesseract4
    ghostscript
    yt-dlp
    streamrip

    # Audio programming
    faust

    # Sync and backup
    rclone
    rsync
    httrack

    # Cloud and deployment
    heroku

    # Mobile development
    android-tools

    # AI and code tools
    claude-code
    opencode
  ] ++ lib.optionals stdenv.isDarwin [ m-cli ];
}
