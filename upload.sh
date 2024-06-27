#!/usr/bin/env bash

set -euxo pipefail

cd ~/Program/nixos-config
cp -fu /etc/nixos/*.nix .
cp -fu /etc/nixos/*.lock .
git add .
git commit -m "update"
git push
