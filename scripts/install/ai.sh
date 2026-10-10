#!/bin/bash

# AI coding agents. For now just the Claude Code CLI, via Anthropic's native
# installer, which puts the binary in ~/.local/bin and keeps it updated itself
# - no sudo, and no Node needed. See https://docs.claude.com/en/docs/claude-code/setup

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

check_command curl || apt_install curl

# The installer links claude into ~/.local/bin. .zshrc puts that on PATH, but
# this script runs under bash, where it may not be yet on a fresh machine -
# without this the already-installed check would miss it and reinstall.
export PATH="$HOME/.local/bin:$PATH"

bash_install https://claude.ai/install.sh claude
