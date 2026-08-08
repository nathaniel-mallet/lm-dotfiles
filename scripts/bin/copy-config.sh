#!/bin/bash

# Copies the shell config out of the repo and into $HOME:
#   config/.zshrc  ->  ~/.zshrc
#   config/*       ->  ~/.zsh/<file>
#
# Anything already in place is moved aside to <file>.backup-<timestamp> first,
# so this is safe to run on a machine that's already set up.

set -euo pipefail

CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../../config"
ZSH_DIR="$HOME/.zsh"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$CONFIG_DIR" ]; then
	echo "Could not find the config directory at $CONFIG_DIR" >&2
	exit 1
fi

# Copies one file into place, backing up whatever was there before.
copy_config() {
	local src="$1" dest="$2"

	# Nothing to do if the file on disk is already the one in the repo -
	# skipping here keeps re-runs from piling up identical backups.
	if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
		echo "$dest - skipped (already up to date)"
		return
	fi

	# -L as well as -e, so a broken symlink still gets moved out of the way
	# rather than being written through.
	if [ -e "$dest" ] || [ -L "$dest" ]; then
		echo "Backing up $dest -> $dest.backup-$TIMESTAMP"
		mv "$dest" "$dest.backup-$TIMESTAMP"
	fi

	echo "Copying $(basename "$src") -> $dest"
	cp "$src" "$dest"
}

copy_config "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"

mkdir -p "$ZSH_DIR"

# Note this glob deliberately doesn't match dotfiles - .zshrc is the only one
# so far and it's handled above. A new dotfile in config/ needs a line here.
for src in "$CONFIG_DIR"/*; do
	[ -f "$src" ] || continue
	copy_config "$src" "$ZSH_DIR/$(basename "$src")"
done

echo "Done - open a new shell or run 'source ~/.zshrc' to pick up the changes."
