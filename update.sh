#!/bin/sh

echo "Updating flake inputs to latest versions..."

# Update all flake inputs to their latest versions
nix flake update

echo "Flake inputs updated. Running garbage collection..."

# Clean up old generations and unused packages
nix-collect-garbage -d

echo "Building updated configuration..."

# Build with the updated inputs
nix build ".#darwinConfigurations.air.system" --impure --fallback --extra-experimental-features 'nix-command flakes'

echo "Switching to updated configuration..."

# Switch to the new configuration
sudo ./result/sw/bin/darwin-rebuild switch --flake . --impure

echo "Update completed successfully!"
echo ""
echo "Summary of changes:"
echo "- Updated all flake inputs (nixpkgs, home-manager, nix-darwin)"
echo "- Cleaned up old system generations"
echo "- Rebuilt and activated your system with latest packages"
