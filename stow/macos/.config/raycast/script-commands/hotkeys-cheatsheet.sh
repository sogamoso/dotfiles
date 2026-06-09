#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Hotkeys Cheatsheet
# @raycast.mode fullOutput
# @raycast.packageName Keyboard

B='\033[1m'     # bold
D='\033[2m'     # dim
C='\033[36m'    # cyan
Y='\033[33m'    # yellow
R='\033[0m'     # reset

echo -e "
${B}${C}── Keyboard Layout ──────────────────────────────────────${R}
${B}Option${R}  ${D}→${R} Window management ${D}(Omarchy: Super)${R}
${B}Command${R} ${D}→${R} App shortcuts + tmux ${D}(Omarchy: Alt)${R}

${B}${C}── Navigating ──────────────────────────────────────────${R}
${B}Option + Space${R}          ${D}Raycast launcher${R}
${B}Option + Escape${R}         ${D}Apple menu (Raycast)${R}
${B}Option + K${R}              ${D}Hotkeys cheatsheet (Raycast)${R}
${B}Option + 1–9${R}           ${D}Switch workspace 1–9${R}
${B}Option + S${R}              ${D}Switch to scratchpad (workspace 10)${R}
${B}Option + Tab${R}            ${D}Next workspace${R}
${B}Option + Shift+Tab${R}      ${D}Previous workspace${R}
${B}Option + Ctrl+Tab${R}       ${D}Former workspace${R}
${B}Option + arrows${R}         ${D}Focus window${R}
${B}Option + Ctrl+arrows${R}    ${D}Move window within workspace${R}
${B}Option + Shift + 1–9${R}   ${D}Move window to workspace (follow)${R}
${B}Option + Shift+S${R}       ${D}Move window to scratchpad (follow)${R}
${B}Option + Shift+Cmd + 1–9${R} ${D}Move window to workspace (stay)${R}
${B}Option + Shift+Cmd+S${R}   ${D}Move window to scratchpad (stay)${R}
${B}Option + W${R}              ${D}Close window${R}
${B}Ctrl + Cmd+Del${R}          ${D}Close all windows, jump to workspace 1${R}
${B}Option + F${R}              ${D}Fullscreen${R}
${B}Option + T${R}              ${D}Toggle floating/tiling${R}
${B}Option + J${R}              ${D}Toggle split direction${R}
${B}Option + L${R}              ${D}Toggle layout${R}
${B}Option + - / =${R}          ${D}Resize width${R}
${B}Option + Shift + - / =${R}  ${D}Resize height${R}

${B}${Y}── Launching Apps ──────────────────────────────────────${R}
${B}Option + Enter${R}          ${D}New Ghostty window${R}
${B}Option + Shift+Enter${R}    ${D}New Chrome window${R}
${B}Option + Shift+N${R}        ${D}New Zed window${R}
${B}Option + Shift+C${R}        ${D}Open Fastmail (calendar)${R}
${B}Option + Shift+E${R}        ${D}Open Fastmail (mail)${R}
${B}Option + Shift+G${R}        ${D}Open WhatsApp${R}
${B}Option + Shift+M${R}        ${D}Open Spotify${R}
${B}Option + Shift+O${R}        ${D}Open Obsidian${R}
${B}Option + Shift+F${R}        ${D}Open Finder${R}
${B}Option + Shift+/${R}        ${D}Open 1Password${R}
${B}Option + Shift+A${R}        ${D}Open Claude${R}
${B}Option + Shift+Y${R}        ${D}Open YouTube${R}
${B}Option + Shift+I${R}        ${D}Open Notion${R}
${B}Option + Shift+L${R}        ${D}Open Linear${R}
${B}Option + Shift+D${R}        ${D}LazyDocker in Ghostty${R}
${B}Option + Shift+Cmd+B${R}    ${D}Chrome incognito${R}
${B}Option + Cmd+Enter${R}      ${D}Ghostty + tmux session${R}

${B}${Y}── System Controls ─────────────────────────────────────${R}
${B}Option + Ctrl+L${R}         ${D}Lock screen${R}
${B}Option + Ctrl+A${R}         ${D}Sound preferences${R}
${B}Option + Ctrl+B${R}         ${D}Bluetooth preferences${R}
${B}Option + Ctrl+W${R}         ${D}Wi-Fi preferences${R}
${B}Option + Ctrl+T${R}         ${D}btop in Ghostty${R}
${B}Option + Ctrl+V${R}         ${D}Clipboard history (Raycast)${R}
${B}Option + Ctrl+E${R}         ${D}Emoji picker (Raycast)${R}
${B}Option + Ctrl+X${R}         ${D}Monologue (dictation)${R}
${B}Mic Mute (F14)${R}          ${D}Toggle mic mute (Lofree mic key)${R}

${B}${Y}── Status Notifications ────────────────────────────────${R}
${B}Option + Ctrl+Cmd+T${R}     ${D}Time / date / week${R}
${B}Option + Ctrl+Cmd+B${R}     ${D}Battery level + state${R}
${B}Option + Ctrl+Cmd+W${R}     ${D}Weather (wttr.in)${R}

${B}${Y}── Capture ─────────────────────────────────────────────${R}
${B}Option + Ctrl+C${R}         ${D}CleanShot all-in-one${R}
${B}Cmd + Shift+6${R}           ${D}CleanShot OCR (assigned in CleanShot)${R}

${B}${Y}── Reminders ───────────────────────────────────────────${R}
${B}Option + Ctrl+R${R}         ${D}Set Reminder (Raycast)${R}
${B}Option + Ctrl+Cmd+R${R}     ${D}Show Reminders (Raycast)${R}
${B}Option + Ctrl+Shift+R${R}   ${D}Clear Reminders (Raycast)${R}

${B}${Y}── Notifications ───────────────────────────────────────${R}
${B}Option + ,${R}              ${D}Toggle Notification Center${R}
${B}Option + Ctrl+,${R}         ${D}Toggle Do Not Disturb${R}

${B}${C}── tmux (prefix = Ctrl+Space) ──────────────────────────${R}
${B}prefix + h / v${R}      ${D}Split horizontal / vertical${R}
${B}prefix + x / k${R}      ${D}Kill pane / window${R}
${B}prefix + c${R}          ${D}New window${R}
${B}prefix + r / R${R}      ${D}Rename window / session${R}
${B}prefix + [${R}          ${D}Copy mode  (v select, y copy)${R}
${B}Cmd + 1–9${R}           ${D}Switch window${R}
${B}Cmd + Left/Right${R}    ${D}Prev / next window${R}
${B}Cmd + Up/Down${R}       ${D}Prev / next session${R}

${B}${C}── Ghostty ─────────────────────────────────────────────${R}
${B}Ctrl+Shift + E${R}          ${D}Split down${R}
${B}Ctrl+Shift + O${R}          ${D}Split right${R}
${B}Ctrl+Shift + T${R}          ${D}New tab${R}
${B}Ctrl+Shift + 1–9${R}        ${D}Go to tab 1–9${R}
${B}Ctrl+Shift + Left/Right${R} ${D}Prev / next tab${R}
${B}Ctrl+Cmd + arrows${R}       ${D}Navigate tmux panes${R}
${B}Ctrl+Cmd+Shift + arrows${R} ${D}Resize tmux panes${R}

${B}${C}── Workspace Layout ────────────────────────────────────${R}
${B}1${R}  ${D}Browse (Chrome, Safari)${R}
${B}2${R}  ${D}Dev (Ghostty, Zed, Solo, Conductor)${R}
${B}3${R}  ${D}Chat (Slack, WhatsApp, Discord)${R}
${B}4${R}  ${D}Mail (Fastmail)${R}
${B}5${R}  ${D}Work (Notion)${R}
${B}6${R}  ${D}Entertainment (Spotify, Podcasts)${R}
${B}7${R}  ${D}Misc${R}
${B}8${R}  ${D}Misc${R}
${B}9${R}  ${D}Misc${R}
${B}10${R} ${D}Scratchpad${R}
"
