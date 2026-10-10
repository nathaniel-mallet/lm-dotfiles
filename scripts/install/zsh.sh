#!/bin/bash

# Installs zsh and makes it the login shell - Ubuntu-based distros default to
# bash, and the config in this repo is zsh-only.

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

apt_install zsh

ZSH_PATH="$(command -v zsh)"
LOGIN_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$LOGIN_SHELL" = "$ZSH_PATH" ]; then
	echo "login shell - skipped (already zsh)"
else
	echo "Changing login shell for $USER to $ZSH_PATH ..."
	# Through sudo so it doesn't ask for the user's password a second time;
	# takes effect at the next login.
	sudo chsh -s "$ZSH_PATH" "$USER"
fi
