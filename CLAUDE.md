# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles and bootstrap scripts for a **Linux Mint** development machine. The goal stated in the README is reproducibility: after a fresh install on another PC, running the scripts here should bring the machine back to a working state.

The machine is used for software development plus a Steam install for play-by-email turns — gaming proper happens on a separate Windows box, so don't add gaming-oriented tuning here beyond what Steam needs.

## Current state — read before planning work

The repo contains only `README.md` and `LICENSE`. **No dotfiles and no install scripts have been committed yet**, despite the README describing them. There is no build, lint, or test command; don't go looking for one.

Consequently, most work here is greenfield. Two decisions are still open, and both change the layout of everything else:

- **How dotfiles get linked into `$HOME`** — GNU Stow, chezmoi, a hand-rolled `install.sh` with symlinks, Nix, or plain copies. Nothing in the repo commits to one.
- **How packages get installed** — Mint is Ubuntu-based, so `apt` covers most CLI tools, but several apps in the list below ship via `.deb` downloads, Flatpak, or vendor apt repos rather than the Mint repos.

Ask before assuming either. Once a convention is chosen, record it here and follow it consistently — a dotfiles repo's value comes from the layout being predictable.

## Target software inventory

The README defines the scope of what these dotfiles configure. Treat it as the source of truth for "does this belong here?" — config for something not on the list probably needs a README update alongside it.

**Apps:** VS Code, Steam, Claude, Codex, Slack, 1Password, WezTerm, Docker

**CLI tools:** Neovim, Starship prompt, fd, ripgrep, eza, bat, lazygit, lazydocker

The CLI list is deliberately a set of modern replacements — `fd` for find, `rg` for grep, `eza` for ls, `bat` for cat. When writing shell aliases, functions, or scripts in this repo, prefer these over the coreutils originals, since the install scripts guarantee their presence.

Of these, the ones that carry real configuration worth versioning are Neovim, WezTerm, Starship, VS Code, lazygit/lazydocker, bat, and the shell itself. Steam, Slack, and 1Password are mostly install-only.

## Environment notes

- Interactive shell on this machine is **zsh**, so shell config work should target zsh unless told otherwise.
- An OpenAI Codex config already exists at `~/.codex/config.toml`. Since Codex is on the install list, that file is a candidate for being versioned here.
- Both Claude and Codex are listed as installed — agent CLI configuration is in scope for this repo, not an afterthought.

## Conventions

Secrets do not belong in this repo — 1Password is the intended home for them. Config that needs a token should read it from the environment or from the 1Password CLI, so the file itself stays safe to commit publicly (the repo is MIT-licensed and clearly meant to be shareable).

Install scripts should be safe to re-run on an already-configured machine, since the stated use case is bootstrapping a fresh install but the practical use is incremental tweaking.
