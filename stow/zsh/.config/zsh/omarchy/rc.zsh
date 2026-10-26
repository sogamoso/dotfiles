# zsh port of Omarchy's default/bash, which only runs in bash on Linux. Each
# file here ports the one of the same name, loaded in the order its rc loads
# them, and says up top what it changes or leaves out, so a diff against
# Omarchy's copy shows real drift. Ported at Omarchy c0b1088 (2026-10-26);
# `dotfiles omarchy-downstream-candidates` reports later changes to default/bash.
for file in envs shell aliases functions init; do
  source "$HOME/.config/zsh/omarchy/$file.zsh"
done
unset file
