#!/bin/sh

nix build ".#darwinConfigurations.air.system" --rebuild --impure --fallback --extra-experimental-features nix-command --extra-experimental-features flakes
./result/sw/bin/darwin-rebuild switch --flake . --impure
