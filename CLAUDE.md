# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles and bootstrap scripts for an **Ubuntu-based** development machine (currently an Ubuntu 24.04 Noble base). The goal stated in the README is reproducibility: after a fresh install on another PC, running the scripts here should bring the machine back to a working state.

The machine is used for software development plus a Steam install for play-by-email turns — gaming proper happens on a separate Windows box, so don't add gaming-oriented tuning here beyond what Steam needs.

## Layout

There is no build, lint, or test command; don't go looking for one. `bash -n <script>` is the cheapest sanity check.

- `install.sh` — the bootstrap entry point. Asks for sudo once, then runs each script in its `STEPS` array, keeps going past failures, and lists them at the end. It warns about any `scripts/install/*.sh` that isn't run, so **a new install script has to be added to `STEPS`** (or run by a script that is already listed).
- `scripts/install/*.sh` — one script per tool or group of tools. Each one sources `scripts/utils.sh` and must be safe to re-run. Current scripts: `zsh.sh` (zsh, oh-my-zsh, login shell), `terminal-tools.sh` (which runs `eza.sh`, `lazygit.sh`, and `gh.sh` itself), `neovim.sh`, `rails.sh` (chruby + ruby-install), `ai.sh` (Claude Code CLI, opencode, and the Orca desktop app), and `desktop_apps.sh` (GUI apps: 1Password and its CLI, Ghostty, KeePassXC, and Chromium from Flathub).
- `scripts/utils.sh` — shared helpers. Use these rather than calling apt or curl directly:
  - `apt_install <pkg>` — skips the package if it's already installed, and runs `apt-get update` at most once per shell.
  - `add_apt_repo <name> <key_url> <sources_line>` — adds a vendor apt repo (keyring in `/etc/apt/keyrings`); install the package from it with `apt_install`.
  - `deb_install <pkg> <url>` — for apps only published as a standalone `.deb`.
  - `bash_install <url> [cmd] [args...]` — for vendor `curl | bash` install scripts. Downloads to a file first, runs it with **bash** (not `sh`/dash), and skips the install when `cmd` is already on PATH.
  - `check_command <cmd>`.
- `scripts/bin/copy-config.sh` — copies `config/.zshrc` to `~/.zshrc` and every other file in `config/` to `~/.zsh/`. It skips files that are already identical, and backs up anything it replaces to `<file>.backup-<timestamp>`.
- `config/` — the shell config: `.zshrc`, `aliases.sh`, `functions.sh`.

## Conventions chosen

- **Dotfiles are copied, not symlinked** (no Stow or chezmoi). Edit the copy in the repo, then re-run `copy-config.sh`. A new dotfile (a name starting with `.`) in `config/` needs its own line in `copy-config.sh`, because the glob there skips dotfiles.
- **Package source preference:** Ubuntu repos via `apt_install` when the packaged version is usable, otherwise the vendor's apt repo (`add_apt_repo`), otherwise GitHub release tarballs or the vendor's install script. When the Ubuntu package is skipped because it's too old or broken (neovim, gh), say why in a comment at the top of the script.
- Release tarballs and other self-managed binaries go in `/usr/local/bin` or `/opt/<tool>`. Per-user installers (Starship, Claude Code) install into `~/.local/bin`, and `.zshrc` puts it on PATH. Scripts that check for those installs should put `~/.local/bin` on PATH themselves, since `install.sh` runs under bash.
- Every install step prints `<name> - skipped (already installed)` when there's nothing to do. Keep that format.
- Scripts use `#!/bin/bash` and tabs for indentation.

Software on the inventory below that has no install script yet: VS Code, Steam, Codex, Slack, Docker. Agent CLIs (Codex next to Claude Code and opencode) and agent tooling such as Orca belong in `ai.sh`, and GUI apps belong in `desktop_apps.sh`.

Some vendor packages (1Password among them) rewrite their own apt source when they're installed. For those, use the vendor's documented keyring path rather than `add_apt_repo`. Otherwise the two sources end up with different `Signed-By` values, and apt refuses to run.

## Target software inventory

The README defines the scope of what these dotfiles configure. Treat it as the source of truth for "does this belong here?" — config for something not on the list probably needs a README update alongside it.

**Apps:** VS Code, Steam, Claude, Codex, Orca, Slack, 1Password, Ghostty, Chromium, KeePassXC, Docker

**CLI tools:** Neovim, Starship prompt, oh-my-zsh, fd, ripgrep, eza, bat, lazygit, lazydocker, gh, opencode

The CLI list is deliberately a set of modern replacements — `fd` for find, `rg` for grep, `eza` for ls, `bat` for cat. When writing shell aliases, functions, or scripts in this repo, prefer these over the coreutils originals, since the install scripts guarantee their presence.

Of these, the ones that carry real configuration worth versioning are Neovim, Ghostty, Starship, VS Code, lazygit/lazydocker, bat, and the shell itself. Steam, Slack, 1Password, Chromium, and KeePassXC are mostly install-only.

## Environment notes

- Interactive shell on this machine is **zsh**, so shell config work should target zsh unless told otherwise.
- An OpenAI Codex config already exists at `~/.codex/config.toml`. Since Codex is on the install list, that file is a candidate for being versioned here.
- Both Claude and Codex are listed as installed — agent CLI configuration is in scope for this repo, not an afterthought.

## Conventions

Secrets do not belong in this repo — 1Password is the intended home for them. Config that needs a token should read it from the environment or from the 1Password CLI, so the file itself stays safe to commit publicly (the repo is MIT-licensed and clearly meant to be shareable).

Install scripts should be safe to re-run on an already-configured machine, since the stated use case is bootstrapping a fresh install but the practical use is incremental tweaking.
