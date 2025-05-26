{ pkgs, ... }:

let
  haskellPackages = pkgs.haskellPackages.override {
    overrides = self: super: {
      ansi-wl-pprint = self.callHackage "ansi-wl-pprint" "0.6.9" {};
      ansi-terminal = self.callHackage "ansi-terminal" "0.11.4" {};
    };
  };
  
  elm-language-server = haskellPackages.callCabal2nix "elm-language-server" (pkgs.fetchFromGitHub {
    owner = "WhileTruu";
    repo = "elm-language-server";
    rev = "language-server";
    sha256 = "0wxjzdqhzpk8ajs4zaxq0xxq2kbgnkp9d7m4fppqqk4srxldrn7s";
  }) {};
in
{
  home.packages = [ elm-language-server ];
}