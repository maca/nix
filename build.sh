#!/bin/sh

# Build the Darwin configuration
echo "Building Darwin configuration..."
nix build ".#darwinConfigurations.air.system" --impure --fallback --extra-experimental-features 'nix-command flakes'

# Switch to the new configuration using sudo
echo "Switching to new configuration..."
sudo ./result/sw/bin/darwin-rebuild switch --flake . --impure

echo "Build and switch completed successfully!"
