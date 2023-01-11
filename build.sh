#!/bin/sh

nix build ".#darwinConfigurations.$(hostname).system" --impure
./result/sw/bin/darwin-rebuild switch --flake . --impure
