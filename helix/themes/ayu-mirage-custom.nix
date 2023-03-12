let
  background = "#1f2430";
  foreground = "#cccac2";

  black = "#1a1f29";
  blue = "#73d0ff";
  dark_blue = "#2baff1";
  dark_gray = "#323843";
  # cyan = "#444b55";
  gray = "#565b66";
  green = "#d5ff80";
  magenta = "#dfbfff";
  orange = "#ffad66";
  red = "#f28779";
  yellow = "#ffcc77";
in
{
  # Syntax highlighting
  "type" = blue;
  "type.builtin" = blue;
  "constructor" = green;
  "constant" = magenta;
  "string" = green;
  "string.regexp" = orange;
  "string.special" = yellow;
  "comment" = { fg = gray; };
  "variable" = foreground;
  "label" = orange;
  "punctuation" = foreground;
  "keyword" = orange;
  "keyword.control" = yellow;
  "keyword.directive" = yellow;
  "operator" = orange;
  "function" = yellow;
  "tag" = blue;
  "namespace" = blue;
  "markup.heading" = orange;
  "markup.list" = yellow;
  "markup.raw.block" = { bg = dark_gray; fg = orange; };
  "markup.link.url" = blue;
  "markup.link.text" = yellow;
  "markup.link.label" = green;
  "markup.quote" = yellow;
  "diff.plus" = green;
  "diff.minus" = "red";
  "diff.delta" = yellow;

  # Interface
  "special" = blue;
  "ui.background" = { bg = background; };
  "ui.cursor" = { fg = dark_gray; bg = blue; };
  "ui.cursor.primary" = { fg = dark_gray; bg = orange; };
  "ui.cursor.primary.select" = { fg = dark_gray; bg = dark_blue; };
  "ui.cursor.match" = orange;
  "ui.linenr" = dark_gray;
  "ui.linenr.selected" = gray;
  "ui.statusline" = { fg = foreground; bg = black; };
  "ui.cursorline" = { bg = black; };
  "ui.popup" = { fg = "#7B91b3"; bg = black; };
  "ui.window" = dark_gray;
  "ui.help" = { fg = "#7B91b3"; bg = black; };
  "ui.text" = foreground;
  "ui.text.focus" = { bg = dark_gray; fg = foreground; };
  "ui.text.info" = foreground;
  "ui.virtual.whitespace" = dark_gray;
  "ui.virtual.ruler" = { bg = black; };
  "ui.menu" = { fg = foreground; bg = black; };
  "ui.menu.selected" = { bg = gray; fg = background; };
  "ui.selection" = { bg = dark_gray; };
  "warning" = yellow;
  "error" = { fg = red; modifiers = [ "bold" ]; };
  "info" = { fg = blue; modifiers = [ "bold" ]; };
  "hint" = { fg = blue; modifiers = [ "bold" ]; };
  "diagnostic.hint" = {
    underline = {
      color = blue;
      style = "curl";
    };
  };
  "diagnostic.info" = {
    underline = {
      color = blue;
      style = "curl";
    };
  };
  "diagnostic.warning" = {
    underline = {
      color = yellow;
      style = "curl";
    };
  };
  "diagnostic.error" = {
    underline = {
      color = red;
      style = "curl";
    };
  };
  "ui.bufferline" = {
    fg = gray;
    bg = "background";
  };
  "ui.bufferline.active" = {
    fg = foreground;
    bg = dark_gray;
  };
}
