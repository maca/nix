{
  description = "My home nix flake";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;

      # User configuration
      userConfig = {
        username = "maca";
        fullName = "Macario Ortega";
        email = "maca@aelita.io";
        signingKey = "6BBF61F857AAD28F42320FE60973371CAB06A408";
      };
    in
    {
      darwinConfigurations = {
        air = darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit userConfig;
          };
          modules = [
            ./systems/darwin/default.nix

            home-manager.darwinModules.home-manager
            {
              nixpkgs = {
                config = { allowUnfree = true; };
                system = "aarch64-darwin";
              };

              users.users.${userConfig.username}.home = "/Users/${userConfig.username}";

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${userConfig.username} = import ./home/default.nix userConfig;
            }
          ];
        };
      };
    };
}
