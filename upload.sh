#!/usr/bin/env bash

set -euxo pipefail

git-se e
git add -A
git commit -m "update"
git-se d
git push

