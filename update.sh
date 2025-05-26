#!/bin/sh

# Get the hostname to determine which configuration to update
HOSTNAME=${1:-$(hostname -s)}

echo "Updating flake inputs to latest versions..."

# Update all flake inputs to their latest versions
nix flake update

echo "Flake inputs updated. Running garbage collection..."

# Clean up old generations and unused packages
nix-collect-garbage -d

echo "Building updated configuration for '$HOSTNAME'..."

# Build with the updated inputs
nix build ".#darwinConfigurations.$HOSTNAME.system" --impure --fallback --extra-experimental-features 'nix-command flakes'

if [ $? -ne 0 ]; then
    echo "Build failed!"
    echo ""
    echo "Available configurations:"
    nix flake show --json . 2>/dev/null | jq -r '.darwinConfigurations | keys[]' 2>/dev/null || echo "  (Unable to list configurations - check your flake.nix)"
    echo ""
    echo "Usage: $0 [hostname]"
    echo "  If no hostname is provided, uses current hostname: $(hostname -s)"
    exit 1
fi

echo "Switching to updated configuration..."

# Switch to the new configuration
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$HOSTNAME" --impure

if [ $? -eq 0 ]; then
    echo "Update completed successfully for '$HOSTNAME'!"
    echo ""
    echo "Summary of changes:"
    echo "- Updated all flake inputs (nixpkgs, home-manager, nix-darwin)"
    echo "- Cleaned up old system generations"
    echo "- Rebuilt and activated your system with latest packages"
    echo ""
    
    # Show what was updated
    echo "Flake input changes:"
    if command -v git >/dev/null 2>&1; then
        git diff HEAD~1 flake.lock 2>/dev/null | grep -E '^\+.*"lastModified"' | head -5 || echo "  (No recent changes to show)"
    fi
else
    echo "Switch failed!"
    exit 1
fi
