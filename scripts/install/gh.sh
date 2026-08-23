#!/bin/bash

# gh is in Ubuntu 24.04 / Mint 22 universe, but that package is 2.45 and the
# GitHub CLI maintainers say it is broken against current APIs. Use their apt
# repo instead. See https://github.com/cli/cli/blob/trunk/docs/install_linux.md

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

check_command curl || apt_install curl

# Guarded internally - skipped if the keyring and sources list are both there.
# The ASCII-armored key works with add_apt_repo(); the .gpg next to it is
# already dearmored and would get mangled by `gpg --dearmor`.
add_apt_repo githubcli \
	"https://cli.github.com/packages/githubcli-archive-keyring.asc" \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main"

apt_install gh
