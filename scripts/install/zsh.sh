#!/bin/bash

# Installs zsh and oh-my-zsh, and makes zsh the login shell - Ubuntu-based
# distros default to bash, and the config in this repo is zsh-only.

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

apt_install zsh
# oh-my-zsh's installer clones itself with git.
apt_install git

ZSH_PATH="$(command -v zsh)"
LOGIN_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$LOGIN_SHELL" = "$ZSH_PATH" ]; then
	echo "login shell - skipped (already zsh)"
else
	echo "Changing login shell for $USER to $ZSH_PATH ..."
	# Through sudo so it doesn't ask for the user's password a second time.
	if sudo chsh -s "$ZSH_PATH" "$USER"; then
		echo "Login shell changed - log out and back in for zsh to become the default shell."
	else
		echo "Could not change the login shell. To do it by hand, run:" >&2
		echo "  chsh -s $ZSH_PATH" >&2
		echo "then log out and back in." >&2
		exit 1
	fi
fi

# oh-my-zsh isn't a command on PATH, so bash_install's skip check doesn't
# apply - check for its install directory instead.
OMZ_DIR="$HOME/.oh-my-zsh"

if [ -d "$OMZ_DIR" ]; then
	echo "oh-my-zsh - skipped (already installed)"
else
	echo "Installing oh-my-zsh ..."
	tmp="$(mktemp -d)"
	if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$tmp/install.sh"; then
		# --unattended: don't chsh (handled above) or drop into zsh at the end.
		# KEEP_ZSHRC: leave an existing ~/.zshrc alone - the one in config/
		# already loads oh-my-zsh, and copy-config.sh puts it in place.
		KEEP_ZSHRC=yes sh "$tmp/install.sh" --unattended
	else
		echo "Failed to download the oh-my-zsh install script" >&2
		rm -rf "$tmp"
		exit 1
	fi
	rm -rf "$tmp"
fi
