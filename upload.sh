#!/usr/bin/env bash

set -euxo pipefail

git-se e
git add -A
git commit -m "update"
if git log -1 --name-only | grep -q "atuin.key"; then
    echo "上一次提交包含隐私文件，脚本终止。"
    exit 1
fi
git-se d
git push

