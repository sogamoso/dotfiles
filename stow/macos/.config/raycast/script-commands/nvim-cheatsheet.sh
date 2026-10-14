#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Neovim Cheatsheet
# @raycast.mode fullOutput
# @raycast.packageName Keyboard

# LazyVim defaults, checked against its keymaps and plugin specs. For the full
# list press Space in Neovim and wait (which-key), or Space s k to search them.

B='\033[1m'     # bold
D='\033[2m'     # dim
C='\033[36m'    # cyan
Y='\033[33m'    # yellow
R='\033[0m'     # reset

echo -e "
${B}${C}── Find (Leader = Space) ───────────────────────────────${R}
${B}space space${R}              ${D}Find files${R}
${B}space /${R}                  ${D}Grep in project${R}
${B}space ,${R}                  ${D}Switch buffer${R}
${B}space f r${R}                ${D}Recent files${R}
${B}space f n${R}                ${D}New file${R}
${B}space e${R}                  ${D}File explorer${R}
${B}space s k${R}                ${D}Search keymaps${R}
${B}space s h${R}                ${D}Search help${R}

${B}${C}── Code ────────────────────────────────────────────────${R}
${B}space c a${R}                ${D}Code action${R}
${B}space c r${R}                ${D}Rename symbol${R}
${B}space c f${R}                ${D}Format${R}
${B}space x x${R}                ${D}Diagnostics (Trouble)${R}
${B}[d${R} / ${B}]d${R}                  ${D}Prev / next diagnostic${R}
${B}gco${R}                      ${D}Add comment below${R}

${B}${Y}── Go to (LSP) ─────────────────────────────────────────${R}
${B}g d${R}                      ${D}Definition${R}
${B}g r${R}                      ${D}References${R}
${B}g I${R}                      ${D}Implementation${R}
${B}g y${R}                      ${D}Type definition${R}
${B}K${R}                        ${D}Hover docs${R}

${B}${C}── Git ─────────────────────────────────────────────────${R}
${B}space g g${R}                ${D}lazygit${R}
${B}space g s${R}                ${D}Git status${R}
${B}space g b${R}                ${D}Blame line${R}

${B}${C}── Buffers & windows ───────────────────────────────────${R}
${B}Shift+h${R} / ${B}Shift+l${R}        ${D}Prev / next buffer${R}
${B}space b d${R}                ${D}Close buffer${R}
${B}space -${R} / ${B}space |${R}        ${D}Split below / right${R}
${B}Ctrl+h/j/k/l${R}             ${D}Move between windows${R}
${B}space w d${R}                ${D}Close window${R}

${B}${C}── Terminal & quit ─────────────────────────────────────${R}
${B}Ctrl+/${R}                   ${D}Toggle terminal${R}
${B}space f t${R}                ${D}Terminal (project root)${R}
${B}space q q${R}                ${D}Quit all${R}
${B}space l${R}                  ${D}Plugin manager (Lazy)${R}
"
