#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Zed Cheatsheet
# @raycast.mode fullOutput
# @raycast.packageName Keyboard

B='\033[1m'     # bold
D='\033[2m'     # dim
C='\033[36m'    # cyan
Y='\033[33m'    # yellow
R='\033[0m'     # reset

echo -e "
${B}${C}── Leader (Space) ──────────────────────────────────────${R}
${B}space space${R} / ${B}space f f${R}   ${D}Find files${R}
${B}space /${R} / ${B}space s g${R}       ${D}Project search (grep)${R}
${B}space ,${R} / ${B}space f b${R}       ${D}Switch buffer (tab switcher)${R}
${B}space f r${R}                ${D}Recent projects${R}
${B}space f k${R}                ${D}Command palette${R}
${B}space e${R}                  ${D}Toggle project panel${R}

${B}${C}── Code Actions (Leader) ───────────────────────────────${R}
${B}space c a${R}                ${D}Code action${R}
${B}space c r${R}                ${D}Rename symbol${R}
${B}space c f${R}                ${D}Format buffer${R}
${B}space x x${R}                ${D}Diagnostics panel${R}

${B}${C}── Git (Leader) ────────────────────────────────────────${R}
${B}space g g${R}                ${D}lazygit (terminal task)${R}
${B}space g b${R}                ${D}Toggle inline blame${R}

${B}${C}── Quit / Close (Leader) ───────────────────────────────${R}
${B}space b d${R}                ${D}Close active buffer${R}
${B}space q q${R}                ${D}Quit Zed${R}

${B}${Y}── LSP / Code Intelligence ─────────────────────────────${R}
${B}g d${R}                      ${D}Go to definition${R}
${B}g r${R}                      ${D}Find all references${R}
${B}g I${R}                      ${D}Go to implementation${R}
${B}g y${R}                      ${D}Go to type definition${R}
${B}K${R}                        ${D}Hover documentation${R}
${B}[ d${R} / ${B}] d${R}              ${D}Prev / next diagnostic${R}
${B}[ c${R} / ${B}] c${R}              ${D}Prev / next git hunk${R}

${B}${Y}── Buffers / Panes ─────────────────────────────────────${R}
${B}Shift+H${R} / ${B}Shift+L${R}      ${D}Prev / next tab${R}
${B}Ctrl+H/J/K/L${R}             ${D}Move focus across panes${R}
${B}Ctrl+S${R}                   ${D}Save file${R}
${B}Cmd+W${R}                    ${D}Close tab${R}
${B}Cmd+\\\\${R}                   ${D}Split right${R}
${B}Cmd+Shift+\\\\${R}             ${D}Split down${R}

${B}${Y}── Built-in Chords ─────────────────────────────────────${R}
${B}Cmd+P${R}                    ${D}Find file${R}
${B}Cmd+Shift+P${R}              ${D}Command palette${R}
${B}Cmd+Shift+F${R}              ${D}Project search${R}
${B}Cmd+B${R}                    ${D}Toggle project panel${R}
${B}Cmd+T${R}                    ${D}Search symbols in file${R}
${B}Cmd+Shift+O${R}              ${D}Search symbols in project${R}
${B}Cmd+Click${R}                ${D}Multi-cursor at click${R}
${B}Ctrl+\\\\${R}                  ${D}Toggle inline assistant${R}

${B}${C}── Vim Mode Essentials ─────────────────────────────────${R}
${B}g c c${R}                    ${D}Toggle comment on line${R}
${B}g c${R} {motion}             ${D}Comment over motion (gcap, gc5j)${R}
${B}y s${R} {motion}{char}       ${D}Surround with char (ysiw\")${R}
${B}c s${R} {old}{new}           ${D}Change surrounding${R}
${B}d s${R} {char}               ${D}Delete surrounding${R}
${B}*${R} / ${B}#${R}                  ${D}Search word forward / back${R}
${B}Ctrl+D${R} / ${B}Ctrl+U${R}        ${D}Half page down / up${R}
${B}z z${R} / ${B}z t${R} / ${B}z b${R}        ${D}Center / top / bottom viewport${R}

${B}${C}── Agent / AI ──────────────────────────────────────────${R}
${B}Cmd+?${R}                    ${D}Toggle agent panel (left dock)${R}
${B}Cmd+Enter${R}                ${D}Send message (in agent panel)${R}
${B}Cmd+I${R}                    ${D}Inline assistant (in editor)${R}
"
