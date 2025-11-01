{ pkgs, lib, ... }:

let
  faust = {
    tree-sitter-faust = pkgs.callPackage ./tree-sitter-faust.nix { };
    faustlsp = pkgs.callPackage ./faustlsp.nix { };
    faustfmt = pkgs.callPackage ./faustfmt.nix { };
    faust2caqt = pkgs.callPackage ./faust2caqt.nix { };
  };
in
{
  home.packages = with faust; [
    faustlsp
    faustfmt
    tree-sitter-faust
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    faust2caqt
  ];
}
