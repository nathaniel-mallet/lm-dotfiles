#!/bin/bash

# Source guard; if this file is sourced more than once,
# this will ensure that its contents aren't redefined.
# It's a bit overkill for now since this file only defines functions,
# but it's good practice in case variables are added later.
if [ -n "$_UTILS_SH_LOADED" ]; then
    return
fi
_UTILS_SH_LOADED=1

# Keep apt from opening debconf dialogs partway through a script.
export DEBIAN_FRONTEND=noninteractive

# apt-get update is slow, and every install script sourcing this file would
# otherwise pay for it again. Run it at most once per shell, lazily, so a
# script that installs nothing new doesn't hit the network at all.
apt_update() {
	if [ -z "$_APT_UPDATED" ]; then
		echo "Updating package lists ..."
		sudo apt-get update -qq
		_APT_UPDATED=1
	fi
}

# Force the next apt_update() to actually run. Call after adding a repo.
apt_update_needed() {
	unset _APT_UPDATED
}

package_installed() {
	dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "^install ok installed$"
}

# Helper function for install messages.
# Named apt_install() rather than install() so it doesn't shadow coreutils
# install(1), which add_apt_repo() below relies on.
apt_install() {
	if package_installed "$1"; then
		echo "$1 - skipped (already installed)"
	else
		echo "installing $1 ..."
		apt_update
		sudo apt-get install -y "$1"
	fi
}

# Replaces yay_install() for the case where a vendor publishes its own apt
# repo (VS Code, Docker, 1Password, ...). Register the repo here, then install
# the package with apt_install() as normal.
#   $1 - short name, used for the keyring and sources.list.d filenames
#   $2 - URL of the vendor's GPG key
#   $3 - full sources line, e.g.
#        "deb [arch=amd64 signed-by=/etc/apt/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main"
add_apt_repo() {
	local name="$1" key_url="$2" repo_line="$3"
	local keyring="/etc/apt/keyrings/${name}.gpg"
	local list="/etc/apt/sources.list.d/${name}.list"

	if [ -f "$list" ] && [ -f "$keyring" ]; then
		echo "$name repo - skipped (already added)"
		return
	fi

	echo "Adding $name apt repo ..."
	sudo install -d -m 0755 /etc/apt/keyrings
	curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring"
	sudo chmod a+r "$keyring"
	echo "$repo_line" | sudo tee "$list" > /dev/null
	apt_update_needed
}

# Replaces yay_install() for the case where an app is only published as a
# standalone .deb download rather than through a repo. Note these don't get
# picked up by apt upgrades - prefer add_apt_repo() when the vendor offers one.
#   $1 - package name, used for the already-installed check
#   $2 - URL of the .deb
deb_install() {
	local pkg="$1" url="$2"

	if package_installed "$pkg"; then
		echo "$pkg - skipped (already installed)"
		return
	fi

	local tmp
	tmp="$(mktemp -d)"
	echo "Installing $pkg from $url ..."
	if curl -fsSL "$url" -o "$tmp/$pkg.deb"; then
		apt_update
		sudo apt-get install -y "$tmp/$pkg.deb"
	else
		echo "Failed to download $pkg from $url" >&2
	fi
	rm -rf "$tmp"
}

# For tools that publish their own install script rather than a package
# (starship, ...), i.e. the `curl -sS <url> | sh` pattern:
#   bash_install https://starship.rs/install.sh
#   $1 - URL of the install script
#   $2 - optional: command the script provides. If given, the install is
#        skipped when that command is already on PATH.
#   $@ - any remaining args are passed through to the install script
bash_install() {
	local url="$1" cmd="${2:-}"
	if [ "$#" -gt 2 ]; then shift 2; else shift "$#"; fi

	if [ -n "$cmd" ] && check_command "$cmd"; then
		echo "$cmd - skipped (already installed)"
		return
	fi

	local tmp
	tmp="$(mktemp -d)"
	echo "Installing ${cmd:-$url} ..."
	# Downloaded to a file first rather than piped straight into the shell, so
	# a connection that drops midway can't leave a half-run script behind.
	# -f matters too: without it a 404 page would get executed as a script.
	if curl -fsSL "$url" -o "$tmp/install.sh"; then
		sh "$tmp/install.sh" "$@"
	else
		echo "Failed to download install script from $url" >&2
	fi
	rm -rf "$tmp"
}

check_command() {
	command -v "$1" &> /dev/null
}
