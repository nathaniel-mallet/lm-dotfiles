#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

bash_install https://starship.rs/install.sh starship
apt_install fd-find
apt_install ripgrep
apt_install fzf
apt_install bat
bash_install https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh lazydocker

# Debian renames both of these to dodge clashes with existing packages (bat ->
# batcat, fd -> fdfind), so link them back to the names the aliases and configs
# in this repo expect. Only when the rename is what actually happened, and only
# when the real name isn't already taken by something else.
if check_command batcat && ! check_command bat; then
	mkdir -p ~/.local/bin
	ln -sf "$(command -v batcat)" ~/.local/bin/bat
fi

if check_command fdfind && ! check_command fd; then
	mkdir -p ~/.local/bin
	ln -sf "$(command -v fdfind)" ~/.local/bin/fd
fi
