{ ... }:
{
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
}
