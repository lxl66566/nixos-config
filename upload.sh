#!/usr/bin/env bash

set -euxo pipefail

cd /etc/nixos-backup
git add .
git commit -m "update"
git push

