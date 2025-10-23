{ userConfig }:
{ pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    
    settings = {
      user = {
        name = userConfig.fullName;
        email = userConfig.email;
      };

      alias = {
        h = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --abbrev-commit --date=short";
        ha = "log --pretty=format:'%Creset%C(red bold)[%ad] %C(blue bold)%h %Creset%C(magenta bold)%d %Creset%s %C(green bold)(%an)%Creset' --graph --all --abbrev-commit --date=short";
        ff = "!branch=$(git symbolic-ref HEAD | cut -d '/' -f 3) && git merge --ff-only $\{1\:-$(git config --get branch.$branch.remote)/$( git config --get branch.$branch.merge | cut -d '/' -f 3)\}";
        dm = "branch --merged | grep -v \* | xargs git branch -D";
        ignore = "update-index --assume-unchanged";
        unignore = "update-index --no-assume-unchanged";
        d = "difftool";
        fg = "forgit";
      };

      pull.rebase = "true";
      init = { defaultBranch = "main"; };
      pager.difftool = true;

      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";

      github.user = builtins.head (lib.splitString "@" userConfig.email);
      gitlab.user = builtins.head (lib.splitString "@" userConfig.email);

      core.excludesfile = "~/.gitignore";
    } // lib.optionalAttrs (userConfig.signingKey != null) {
      commit.gpgsign = true;
      user.signingkey = userConfig.signingKey;
    };

    ignores = [ "*.swp" "*.claude/" ];
  };
}
