#!/bin/bash

# AI coding agents and the tools around them:
# - Claude Code CLI, via Anthropic's native installer, which puts the binary in
#   ~/.local/bin and keeps it updated itself - no sudo, and no Node needed.
#   See https://docs.claude.com/en/docs/claude-code/setup
# - opencode, via its own installer, which puts the binary in ~/.opencode/bin.
#   See https://opencode.ai/docs/
# - Orca, a desktop app for running several agents side by side. It has no apt
#   repo, so it comes from the .deb on its latest GitHub release.
#   See https://github.com/stablyai/orca

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

check_command curl || apt_install curl

status=0

# Both installers link into dirs that .zshrc puts on PATH, but this script runs
# under bash, where they may not be on PATH yet on a fresh machine - without
# this the already-installed checks would miss them and reinstall.
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

bash_install https://claude.ai/install.sh claude

# --no-modify-path: the installer would otherwise append a PATH line to
# ~/.zshrc, which is a copy of config/.zshrc and gets overwritten by
# copy-config.sh. config/.zshrc adds ~/.opencode/bin itself.
bash_install https://opencode.ai/install opencode --no-modify-path

# The package is orca-ide, and so is the command: plain `orca` is the GNOME
# screen reader. The .deb filename carries the version, so find the latest
# release tag by following GitHub's /releases/latest redirect (no API token or
# gh needed). A .deb isn't upgraded by apt - to update Orca, remove it and
# re-run this script, or use the app's own updater.
if package_installed orca-ide; then
	echo "orca-ide - skipped (already installed)"
else
	arch="$(dpkg --print-architecture)"
	tag="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/stablyai/orca/releases/latest)"
	tag="${tag##*/}"
	case "$arch" in
	amd64 | arm64)
		if [ -n "$tag" ] && [ "$tag" != latest ]; then
			deb_install orca-ide "https://github.com/stablyai/orca/releases/download/$tag/orca-ide_${tag#v}_${arch}.deb"
		else
			echo "orca-ide - failed to find the latest release" >&2
		fi
		;;
	*)
		echo "orca-ide - skipped (no .deb for $arch)" >&2
		;;
	esac
fi
# deb_install doesn't return non-zero on a failed download, so check the
# result directly to let install.sh report it.
package_installed orca-ide || status=1

exit $status
