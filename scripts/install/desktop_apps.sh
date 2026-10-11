#!/bin/bash

# GUI desktop apps. Each one comes from apt (the Ubuntu repos, or the vendor's
# apt repo when Ubuntu doesn't package it), so they get updates through normal
# apt upgrades. Ghostty and Chromium are the exceptions - see below.

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

# Ghostty - https://ghostty.org/docs/install/binary
# Not in the Ubuntu repos before 26.04, and the project publishes no apt repo
# or .deb of its own. Its docs point Ubuntu 24.04 users at the community
# ghostty-ubuntu .debs, installed via that project's script (which knows Pop!_OS
# by name and maps it to the matching Ubuntu build). The .deb doesn't come from
# a repo, so apt won't upgrade it - to update, run the script again by hand.
bash_install https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh ghostty || status=1

# KeePassXC - the Ubuntu package is recent enough.
apt_install keepassxc || status=1

# Chromium - from Flathub rather than apt. Ubuntu's chromium-browser package is
# just a transitional wrapper that installs the snap, and snapd isn't installed
# on this machine (Pop!_OS doesn't ship it). Google publishes no Chromium apt
# repo. Installed per user, which is where Pop!_OS already has flathub set up.
CHROMIUM_ID=org.chromium.Chromium

check_command flatpak || apt_install flatpak
if flatpak info --user "$CHROMIUM_ID" &> /dev/null; then
	echo "chromium - skipped (already installed)"
else
	echo "installing chromium ..."
	flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &&
		flatpak install --user -y --noninteractive flathub "$CHROMIUM_ID" || status=1
fi

exit $status
