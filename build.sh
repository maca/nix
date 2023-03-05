#!/bin/sh

nix build ".#darwinConfigurations.$(hostname).system" --impure --fallback
./result/sw/bin/darwin-rebuild switch --flake . --impure
