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
    zsh-forgit
    gitui
    gh
    nixpkgs-fmt
    nil
    zplug
    cloc
    ssh-copy-id
    heroku
    shared-mime-info
    ffmpeg
    imagemagick
    graphviz
    vimv
    pgcli
    jq
    yq
    postgresql
    stack
    podman
    qemu
    buildah
    docker-compose
    (ruby.withPackages (ps: with ps; [ nokogiri pry pg rails minitest ]))
    elmPackages.elm
    elmPackages.elm-doc-preview
    elmPackages.elm-live
    elmPackages.elm-test
    elmPackages.elm-language-server
    elmPackages.elm-review
    redocly
    marksman
    markdown-oxide
    dprint
    pandoc
    nodejs_22
    yarn
    nodePackages.typescript-language-server
    yarn2nix
    node2nix
    nodePackages.ts-node
    elixir
    gleam
    tesseract4
    ghostscript
    yt-dlp
    retry
    httrack
    rclone
    rsync
    borgbackup
    python3Packages.llfuse
    android-tools
    claude-code
    sass
  ] ++ lib.optionals stdenv.isDarwin [ m-cli ];
}
