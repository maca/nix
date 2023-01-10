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
    extraConfig = ''
      (setq standard-indent 2)
    '';
  }; 

  programs.git = {
    enable = true;
    userName  = "Macario Ortega";
    userEmail = "maca@aelita.io";

    aliases = {
      h = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --abbrev-commit --date=short";
      ha = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --all --abbrev-commit --date=short";

      ignore = "update-index --assume-unchanged";
      unignore = "update-index --no-assume-unchanged";
    };
  };

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget

    # Dev stuff
    jq
    nodejs

    yarn
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}
