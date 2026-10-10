#!/bin/bash

# eza isn't in the Ubuntu repos, so it comes from the maintainer's own apt
# repo. See https://github.com/eza-community/eza/blob/main/INSTALL.md

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

check_command curl || apt_install curl

# Guarded internally - skipped if the keyring and sources list are both there.
add_apt_repo gierens \
	"https://raw.githubusercontent.com/eza-community/eza/main/deb.asc" \
	"deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main"

apt_install eza
