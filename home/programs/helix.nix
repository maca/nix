{ ... }:
{
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
        end-of-line-diagnostics = "warning";
        inline-diagnostics = {
          cursor-line = "hint";
        };
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
}
