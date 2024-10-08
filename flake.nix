{
  description = "My home nix flake";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
    in
    {
      darwinConfigurations = {
        air = darwinSystem {
          system = "aarch64-darwin";

          modules = [
            ./darwin.nix

            home-manager.darwinModules.home-manager
            {
              nixpkgs = {
                config = { allowUnfree = true; };
                system = "aarch64-darwin";
                overlays = [ inputs.emacs-overlay.overlay ];
              };

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.maca = import ./home.nix;
            }
          ];
        };
      };
    };
}
