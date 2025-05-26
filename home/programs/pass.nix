{ pkgs, config, ... }:
{
  programs.browserpass.enable = true;

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      PASSWORD_STORE_CLIP_TIME = "60";
    };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };
}
