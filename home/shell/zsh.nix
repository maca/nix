{ pkgs, ... }:
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
    initContent = ''
      PATH="$(${pkgs.yarn}/bin/yarn global bin):$PATH"
      PATH="$HOME/.local/bin:$PATH"

      source <(fzf --zsh)

      [ -f ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh ] &&
        source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh
      PATH="$PATH:$FORGIT_INSTALL_DIR/bin"
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
