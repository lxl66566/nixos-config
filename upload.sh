#!/usr/bin/env bash

set -euxo pipefail

git-se d
cp ../nixos/config/absx.dae ./config/
git-se e
git add .
git commit -m "update"
git push

