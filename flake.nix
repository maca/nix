{
  description = "My home nix flake";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;
    inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

  in
  {
    darwinConfigurations = rec {
      VNDR-A436 = darwinSystem {
        system = "aarch64-darwin";

        modules = [
          ./configuration.nix

          home-manager.darwinModules.home-manager
          {
            nixpkgs = {
              config = { allowUnfree = true; };
              system = "aarch64-darwin";
              overlays = [ inputs.emacs-overlay.overlay ];
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.macarioortega = import ./home.nix;
          }
        ];
      };
    };
  };
}
