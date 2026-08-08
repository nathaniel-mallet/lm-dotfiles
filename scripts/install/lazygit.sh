#!/bin/bash

# lazygit only reached the Ubuntu repos in 24.04, and not Mint's, so it gets
# pulled from the project's GitHub releases instead.

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

if check_command lazygit; then
	echo "lazygit - skipped (already installed)"
	exit 0
fi

check_command curl || apt_install curl

# The API call is rate limited (60/hr for anonymous requests), so an empty
# version here is expected often enough to be worth checking - without it the
# download URL silently becomes .../download/v/lazygit__Linux_x86_64.tar.gz.
LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
if [ -z "$LAZYGIT_VERSION" ]; then
	echo "Could not determine the latest lazygit version - skipping" >&2
	exit 1
fi

LAZYGIT_ARCH=$(uname -m | sed -e 's/aarch64/arm64/')

# Unpack in a temp dir so a re-run doesn't leave a tarball behind in whatever
# directory the script happened to be called from.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Installing lazygit $LAZYGIT_VERSION ..."
url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
if ! curl -fsSL -o "$tmp/lazygit.tar.gz" "$url"; then
	echo "Failed to download lazygit $LAZYGIT_VERSION for $LAZYGIT_ARCH" >&2
	exit 1
fi

tar xf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
sudo install "$tmp/lazygit" -D -t /usr/local/bin/
