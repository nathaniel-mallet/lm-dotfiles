#!/bin/bash

# Bootstraps the machine: runs every script in scripts/install, then copies
# the shell config into $HOME. Every step is safe to re-run, so this is also
# the way to pick up a newly added script on an already-configured machine.
#
# A failing step doesn't stop the run - the rest still go ahead, and the
# failures are listed at the end.

set -u

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$REPO_DIR/scripts/install"

# zsh goes first, since the config copied at the end is zsh-only.
# terminal-tools.sh runs eza.sh, lazygit.sh and gh.sh itself, so they can be
# installed together without the rest - they aren't listed separately here.
# New scripts in scripts/install need adding here too.
STEPS=(
	"$INSTALL_DIR/zsh.sh"
	"$INSTALL_DIR/terminal-tools.sh"
	"$INSTALL_DIR/neovim.sh"
	"$INSTALL_DIR/rails.sh"
	"$INSTALL_DIR/ai.sh"
	"$INSTALL_DIR/desktop_apps.sh"
	"$REPO_DIR/scripts/bin/copy-config.sh"
)

# Ask for the sudo password once up front rather than partway through.
sudo -v || exit 1

failed=()
for step in "${STEPS[@]}"; do
	echo
	echo "==> ${step#"$REPO_DIR"/}"
	if ! bash "$step"; then
		failed+=("${step#"$REPO_DIR"/}")
	fi
done

# Catch scripts that were added to scripts/install but not to STEPS above.
# Ones a step runs itself (like terminal-tools.sh -> eza.sh) don't count.
for script in "$INSTALL_DIR"/*.sh; do
	if [[ ! " ${STEPS[*]} " == *" $script "* ]] && \
		! \grep -qF "/$(basename "$script")" "${STEPS[@]}"; then
		echo "Warning: ${script#"$REPO_DIR"/} isn't listed in install.sh and was not run" >&2
	fi
done

echo
if [ "${#failed[@]}" -gt 0 ]; then
	echo "Finished with failures:" >&2
	printf '  %s\n' "${failed[@]}" >&2
	exit 1
fi

echo "All done - log out and back in for the zsh login shell to take effect."
