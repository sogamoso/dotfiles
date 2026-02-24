## Dotfiles

Personal dotfiles layered on top of [Omamac](https://github.com/omacom-io/omamac). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

Omamac handles the base macOS setup (Omadots, core packages, Ghostty, Hammerspoon, Rectangle Pro, Raycast, macOS defaults). This repo adds personal packages, aliases, security hardening, and configs.

### Installation

Simply run:

    ./bootstrap

This installs Omamac first (if not already present), then applies personal customizations. You can safely run `./bootstrap` multiple times to update.
