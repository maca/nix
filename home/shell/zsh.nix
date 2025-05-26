{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
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
      zplugHome = "${config.home.homeDirectory}/.config/zplug";
    };
    initContent = ''
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
}
