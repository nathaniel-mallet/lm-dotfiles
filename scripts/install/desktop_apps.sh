#!/bin/bash

# GUI desktop apps. Each one comes from its vendor's apt repo (or .deb) rather
# than the Ubuntu repos, so they get updates through normal apt upgrades.

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

check_command curl || apt_install curl

status=0

# 1Password - https://support.1password.com/install-linux/#debian-or-ubuntu
# Installs the app and its CLI (`op`, which config in this repo uses to read
# secrets). The CLI lives here rather than in terminal-tools.sh since it comes
# from the same apt repo.
#
# The repo isn't added with add_apt_repo(): once installed, the 1password
# package takes over its own repo config (writing 1password.sources and
# commenting out 1password.list), signed with the keyring at the path below. A
# second source signed with a different keyring path would make apt fail with
# "Conflicting values set for option Signed-By", so stick to 1Password's own
# path, and leave the repo alone if either file is already there.
# The apt repo is amd64 only.
OP_KEYRING=/usr/share/keyrings/1password-archive-keyring.gpg

if package_installed 1password && package_installed 1password-cli; then
	echo "1password - skipped (already installed)"
	echo "1password-cli - skipped (already installed)"
elif [ "$(dpkg --print-architecture)" != amd64 ]; then
	echo "1password - skipped (apt repo is amd64 only)" >&2
	status=1
else
	if [ -f "$OP_KEYRING" ] && { [ -f /etc/apt/sources.list.d/1password.sources ] || [ -f /etc/apt/sources.list.d/1password.list ]; }; then
		echo "1password repo - skipped (already added)"
	else
		echo "Adding 1password apt repo ..."
		curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | \
			sudo gpg --dearmor --yes -o "$OP_KEYRING"
		echo "deb [arch=amd64 signed-by=$OP_KEYRING] https://downloads.1password.com/linux/debian/amd64 stable main" | \
			sudo tee /etc/apt/sources.list.d/1password.list > /dev/null
		apt_update_needed
	fi
	apt_install 1password || status=1
	apt_install 1password-cli || status=1
fi

exit $status
