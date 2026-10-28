#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Zed Cheatsheet
# @vicinae.mode fullOutput
# @vicinae.packageName Keyboard

# Laid out like the Neovim cheatsheet, since ~/.config/zed/keymap.json binds
# LazyVim's keys to their Zed equivalents; change this along with that file. The
# rest are Zed's vim mode and macOS defaults.
set -euo pipefail
source "$HOME/.config/dotfiles/lib/cheatsheet.sh"

# Key and description are tab separated
cheatsheet "Zed Cheatsheet" <<'EOF'
## Find (Leader = Space)
space space	Find files
space /	Grep in project
space ,	Switch buffer
space f r	Recent files (top of the file finder)
space f p	Recent projects
space f n	New file
space e	File explorer
space s k	Search keymaps
space s C	Command palette

## Code
space c a	Code action
space c r	Rename symbol
space c f	Format
space x x	Diagnostics panel
[d / ]d	Prev / next diagnostic
gcc / Cmd + /	Toggle comment

## Go to (LSP)
g d	Definition
g r	References
g I	Implementation
g y	Type definition
K	Hover docs

## Git
space g g	lazygit
space g s	Git panel
space g b	Blame line
[c / ]c	Prev / next hunk

## Buffers & windows
Shift + H / Shift + L	Prev / next buffer
space b d	Close buffer
space - / space |	Split below / right
Ctrl + H/J/K/L	Move between windows
space w d	Close window

## Terminal & quit
Ctrl + /	Toggle terminal
space f t	Terminal
space q q	Quit
space l	Extensions

## Agent
Cmd + ?	Toggle agent panel (right dock)
Enter	Send message (in agent panel)
Ctrl + Enter	Inline assistant
EOF
