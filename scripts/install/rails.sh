#!/bin/bash

# chruby (switches between installed rubies) and ruby-install (builds them),
# both from https://github.com/postmodern. Neither is packaged for Ubuntu, so
# they're built from their release tarballs with `make install`, which puts
# chruby.sh in /usr/local/share/chruby/ where .zshrc expects it.
#
# This doesn't install a ruby itself - run e.g. `ruby-install ruby` afterwards.

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

check_command curl || apt_install curl
apt_install make

# Resolves the latest release tag by following GitHub's releases/latest
# redirect, which unlike the API isn't rate limited.
#   $1 - repo, e.g. postmodern/chruby
latest_version() {
	curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" | \grep -Po '/tag/v\K[^/]+$'
}

# Downloads, unpacks and `make install`s one of postmodern's projects.
#   $1 - project name, e.g. chruby
postmodern_install() {
	local name="$1" version tmp

	version=$(latest_version "postmodern/$name")
	if [ -z "$version" ]; then
		echo "Could not determine the latest $name version - skipping" >&2
		return 1
	fi

	tmp=$(mktemp -d)
	echo "Installing $name $version ..."
	local rc=0
	if curl -fsSL -o "$tmp/$name.tar.gz" "https://github.com/postmodern/$name/releases/download/v$version/$name-$version.tar.gz"; then
		tar xzf "$tmp/$name.tar.gz" -C "$tmp" && sudo make -C "$tmp/$name-$version" install || rc=1
	else
		echo "Failed to download $name $version" >&2
		rc=1
	fi
	rm -rf "$tmp"
	return $rc
}

status=0

if [ -f /usr/local/share/chruby/chruby.sh ]; then
	echo "chruby - skipped (already installed)"
else
	postmodern_install chruby || status=1
fi

if check_command ruby-install; then
	echo "ruby-install - skipped (already installed)"
else
	postmodern_install ruby-install || status=1
fi

exit $status
