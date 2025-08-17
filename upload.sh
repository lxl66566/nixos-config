#!/usr/bin/env bash

set -euxo pipefail

os_kernel=$(uname -s | tr '[:upper:]' '[:lower:]')

if [[ "$os_kernel" == "linux" ]] && ! grep -q -E "(Microsoft|WSL)" /proc/version &>/dev/null; then
	chmod 0640 config/absx.dae config/example.dae
	dae validate -c config/absx.dae
	dae validate -c config/example.dae
fi

git-se e
git add -A
git commit -a --allow-empty-message -m "$*"
if git log -1 --name-only | grep -q "atuin.key"; then
	echo "上一次提交包含隐私文件，脚本终止。"
	exit 1
fi
git-se d
git push
