#!/usr/bin/env bash

# @vicinae.schemaVersion 1
# @vicinae.title Zed Cheatsheet
# @vicinae.mode fullOutput
# @vicinae.packageName Keyboard

# Laid out like the Neovim cheatsheet, since ~/.config/zed/keymap.json binds
# LazyVim's keys to their Zed equivalents; change this along with that file. The
# rest are Zed's vim mode and macOS defaults.

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
${B}space f r${R}                ${D}Recent files (top of the file finder)${R}
${B}space f p${R}                ${D}Recent projects${R}
${B}space f n${R}                ${D}New file${R}
${B}space e${R}                  ${D}File explorer${R}
${B}space s k${R}                ${D}Search keymaps${R}
${B}space s C${R}                ${D}Command palette${R}

${B}${C}── Code ────────────────────────────────────────────────${R}
${B}space c a${R}                ${D}Code action${R}
${B}space c r${R}                ${D}Rename symbol${R}
${B}space c f${R}                ${D}Format${R}
${B}space x x${R}                ${D}Diagnostics panel${R}
${B}[d${R} / ${B}]d${R}                  ${D}Prev / next diagnostic${R}
${B}gcc${R} / ${B}Cmd+/${R}              ${D}Toggle comment${R}

${B}${Y}── Go to (LSP) ─────────────────────────────────────────${R}
${B}g d${R}                      ${D}Definition${R}
${B}g r${R}                      ${D}References${R}
${B}g I${R}                      ${D}Implementation${R}
${B}g y${R}                      ${D}Type definition${R}
${B}K${R}                        ${D}Hover docs${R}

${B}${C}── Git ─────────────────────────────────────────────────${R}
${B}space g g${R}                ${D}lazygit${R}
${B}space g s${R}                ${D}Git panel${R}
${B}space g b${R}                ${D}Blame line${R}
${B}[c${R} / ${B}]c${R}                  ${D}Prev / next hunk${R}

${B}${C}── Buffers & windows ───────────────────────────────────${R}
${B}Shift+h${R} / ${B}Shift+l${R}        ${D}Prev / next buffer${R}
${B}space b d${R}                ${D}Close buffer${R}
${B}space -${R} / ${B}space |${R}        ${D}Split below / right${R}
${B}Ctrl+h/j/k/l${R}             ${D}Move between windows${R}
${B}space w d${R}                ${D}Close window${R}

${B}${C}── Terminal & quit ─────────────────────────────────────${R}
${B}Ctrl+/${R}                   ${D}Toggle terminal${R}
${B}space f t${R}                ${D}Terminal${R}
${B}space q q${R}                ${D}Quit${R}
${B}space l${R}                  ${D}Extensions${R}

${B}${Y}── Agent ───────────────────────────────────────────────${R}
${B}Cmd+?${R}                    ${D}Toggle agent panel (right dock)${R}
${B}Enter${R}                    ${D}Send message (in agent panel)${R}
${B}Ctrl+Enter${R}               ${D}Inline assistant${R}
"
