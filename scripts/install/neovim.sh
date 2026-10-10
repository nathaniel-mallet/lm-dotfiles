#!/bin/bash

# The neovim package in Ubuntu 24.04 is 0.9, which is too old for most current
# plugins, so install the official release tarball into /opt/nvim instead.
# .zshrc puts /opt/nvim/bin on PATH.
# See https://github.com/neovim/neovim/blob/master/INSTALL.md

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

NVIM_DIR=/opt/nvim

if [ -x "$NVIM_DIR/bin/nvim" ]; then
	echo "neovim - skipped (already installed)"
	exit 0
fi

check_command curl || apt_install curl

NVIM_ARCH=$(uname -m | sed -e 's/aarch64/arm64/')

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Installing neovim ..."
url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
if ! curl -fsSL -o "$tmp/nvim.tar.gz" "$url"; then
	echo "Failed to download neovim for $NVIM_ARCH" >&2
	exit 1
fi

# The tarball's top-level directory is nvim-linux-<arch>; strip it so the
# install path doesn't depend on the architecture.
sudo rm -rf "$NVIM_DIR"
sudo mkdir -p "$NVIM_DIR"
sudo tar xzf "$tmp/nvim.tar.gz" -C "$NVIM_DIR" --strip-components=1
