#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../utils.sh"

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

# These need more than an apt install, so they live in their own scripts.
# Keep going if one fails, but exit non-zero so install.sh reports it.
status=0
"$SCRIPT_DIR/eza.sh" || status=1
"$SCRIPT_DIR/lazygit.sh" || status=1
"$SCRIPT_DIR/gh.sh" || status=1
exit $status
