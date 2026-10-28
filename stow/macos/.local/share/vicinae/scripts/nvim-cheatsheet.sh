#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Neovim Cheatsheet
# @vicinae.mode fullOutput
# @vicinae.packageName Keyboard

# LazyVim defaults, checked against its keymaps and plugin specs. For the full
# list press Space in Neovim and wait (which-key), or Space s k to search them.
set -euo pipefail
source "$HOME/.config/dotfiles/lib/cheatsheet.sh"

# Key and description are tab separated
cheatsheet "Neovim Cheatsheet" <<'EOF'
## Find (Leader = Space)
space space	Find files
space /	Grep in project
space ,	Switch buffer
space f r	Recent files
space f n	New file
space e	File explorer
space s k	Search keymaps
space s h	Search help

## Code
space c a	Code action
space c r	Rename symbol
space c f	Format
space x x	Diagnostics (Trouble)
[d / ]d	Prev / next diagnostic
gco	Add comment below

## Go to (LSP)
g d	Definition
g r	References
g I	Implementation
g y	Type definition
K	Hover docs

## Git
space g g	lazygit
space g s	Git status
space g b	Blame line

## Buffers & windows
Shift + H / Shift + L	Prev / next buffer
space b d	Close buffer
space - / space |	Split below / right
Ctrl + H/J/K/L	Move between windows
space w d	Close window

## Terminal & quit
Ctrl + /	Toggle terminal
space f t	Terminal (project root)
space q q	Quit all
space l	Plugin manager (Lazy)
EOF
