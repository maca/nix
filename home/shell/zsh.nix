{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "ls --color";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "ssh-agent" "pass" "emoji" "transfer" "vi-mode" ];
      extraConfig = "zstyle :omz:plugins:ssh-agent identities id_rsa";
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
      zplugHome = "${config.home.homeDirectory}/.config/zplug";
    };
    initContent = ''
      PATH="$(${pkgs.yarn}/bin/yarn global bin):$PATH"
      source <(fzf --zsh)
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
