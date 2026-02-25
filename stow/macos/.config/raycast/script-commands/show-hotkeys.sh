#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Show Hotkeys
# @raycast.mode silent
# @raycast.packageName Utilities
# @raycast.icon ⌨️

# Generates a styled HTML cheatsheet and opens it in the default browser.
# Data mirrors the `hotkeys` shell function from hotkeys.zsh.

FILE="/tmp/hotkeys-cheatsheet.html"

cat > "$FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Keyboard Shortcuts</title>
<style>
  :root {
    --bg:        #1a1b26;
    --surface:   #24283b;
    --border:    #414868;
    --muted:     #565f89;
    --text:      #a9b1d6;
    --bright:    #c0caf5;
    --accent:    #bb9af7;
    --key:       #7aa2f7;
    --row-hover: #292e42;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html { background: var(--bg); }
  body {
    background: var(--bg);
    color: var(--bright);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Inter", system-ui, sans-serif;
    padding: 48px 40px 64px;
    -webkit-font-smoothing: antialiased;
  }

  /* Header */
  header {
    text-align: center;
    margin-bottom: 40px;
  }
  header h1 {
    font-size: 22px;
    font-weight: 700;
    color: var(--accent);
    letter-spacing: 2px;
    text-transform: uppercase;
  }
  header p {
    font-size: 13px;
    color: var(--muted);
    margin-top: 6px;
  }

  /* Grid */
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(370px, 1fr));
    gap: 20px;
    max-width: 1100px;
    margin: 0 auto;
  }

  /* Cards */
  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 20px 22px 16px;
  }
  .card h2 {
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.8px;
    color: var(--accent);
    margin-bottom: 2px;
  }
  .card .tool {
    font-size: 11px;
    color: var(--muted);
    margin-bottom: 14px;
  }

  /* Subsection header inside a card */
  .sub {
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    color: var(--muted);
    padding: 12px 0 6px;
    border-top: 1px solid var(--border);
    margin-top: 4px;
  }

  /* Tables */
  table { width: 100%; border-collapse: collapse; }
  tr { border-bottom: 1px solid rgba(65,72,104,0.35); }
  tr:last-child { border-bottom: none; }
  tr:hover { background: var(--row-hover); }
  td { padding: 7px 2px; font-size: 14px; vertical-align: middle; }
  td:first-child {
    white-space: nowrap;
    padding-right: 16px;
  }
  td:last-child {
    color: var(--text);
    text-align: right;
  }

  /* Keyboard keys */
  kbd {
    display: inline-block;
    background: var(--bg);
    border: 1px solid var(--border);
    border-bottom-width: 2px;
    border-radius: 5px;
    padding: 2px 7px;
    font-family: -apple-system, "SF Pro Text", system-ui, sans-serif;
    font-size: 13px;
    color: var(--key);
    min-width: 22px;
    text-align: center;
    line-height: 1.4;
  }
  .sep {
    display: inline-block;
    color: var(--muted);
    font-size: 11px;
    margin: 0 2px;
  }

  /* Legend */
  .legend {
    text-align: center;
    margin-top: 36px;
    color: var(--muted);
    font-size: 13px;
    line-height: 2;
  }
  .legend kbd {
    font-size: 12px;
    margin: 0 1px;
    vertical-align: 1px;
  }
  .legend span {
    margin: 0 10px;
  }

  /* Prefix note */
  .prefix {
    font-size: 12px;
    color: var(--muted);
    margin-bottom: 10px;
  }
  .prefix kbd {
    font-size: 11px;
    vertical-align: 1px;
  }
</style>
</head>
<body>

<header>
  <h1>Keyboard Shortcuts</h1>
  <p>All custom keybindings at a glance</p>
</header>

<div class="grid">

  <!-- APP LAUNCHING -->
  <div class="card">
    <h2>App Launching</h2>
    <div class="tool">Raycast</div>
    <table>
      <tr><td><kbd>⌘</kbd> <kbd>Space</kbd></td><td>Raycast Launcher</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>⏎</kbd></td><td>New Ghostty Window</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>A</kbd> <kbd>⏎</kbd></td><td>New Alacritty Window</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>⇧</kbd> <kbd>⏎</kbd></td><td>New Chrome Window</td></tr>
    </table>
  </div>

  <!-- WINDOW NAVIGATION -->
  <div class="card">
    <h2>Window Navigation</h2>
    <div class="tool">Hammerspoon</div>
    <table>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>→</kbd></td><td>Focus window right</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>←</kbd></td><td>Focus window left</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>↑</kbd></td><td>Focus window above</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌃</kbd> <kbd>↓</kbd></td><td>Focus window below</td></tr>
    </table>
  </div>

  <!-- WINDOW POSITIONING -->
  <div class="card">
    <h2>Window Positioning</h2>
    <div class="tool">Rectangle Pro</div>
    <table>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>←</kbd> <span class="sep">/</span> <kbd>→</kbd></td><td>Left / Right Half</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>↑</kbd> <span class="sep">/</span> <kbd>↓</kbd></td><td>Top / Bottom Left Quarter</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>⇧</kbd> <kbd>↑</kbd> <span class="sep">/</span> <kbd>↓</kbd></td><td>Top / Bottom Right Quarter</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>⌃</kbd> <kbd>←</kbd> <span class="sep">/</span> <kbd>→</kbd></td><td>First / Last Fourth</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>⌃</kbd> <kbd>↑</kbd> <span class="sep">/</span> <kbd>↓</kbd></td><td>Top / Bottom Left Eighth</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>⌃</kbd> <kbd>⇧</kbd> <kbd>↑</kbd> <span class="sep">/</span> <kbd>↓</kbd></td><td>Top / Bottom Right Eighth</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>⏎</kbd></td><td>Center Half</td></tr>
      <tr><td><kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>⌃</kbd> <kbd>⏎</kbd></td><td>Maximize</td></tr>
    </table>
  </div>

  <!-- TMUX -->
  <div class="card">
    <h2>Tmux</h2>
    <div class="tool">Terminal multiplexer</div>
    <div class="prefix">Prefix: <kbd>⌃</kbd> <kbd>Space</kbd> &nbsp;(or <kbd>⌃</kbd> <kbd>B</kbd>)</div>

    <!-- Panes -->
    <table>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>PgUp</kbd></td><td>Split horizontally</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>PgDn</kbd></td><td>Split vertically</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>End</kbd></td><td>Kill pane</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>←</kbd> <span class="sep">/</span> <kbd>→</kbd></td><td>Focus left / right pane</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>↑</kbd> <span class="sep">/</span> <kbd>↓</kbd></td><td>Focus up / down pane</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>⇧</kbd> <kbd>←</kbd> <span class="sep">/</span> <kbd>→</kbd></td><td>Resize left / right</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>⇧</kbd> <kbd>↑</kbd> <span class="sep">/</span> <kbd>↓</kbd></td><td>Resize up / down</td></tr>
    </table>

    <div class="sub">Windows</div>
    <table>
      <tr><td><kbd>⌃</kbd> <kbd>⇧</kbd> <kbd>Home</kbd></td><td>New window</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⇧</kbd> <kbd>End</kbd></td><td>Kill window</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⇧</kbd> <kbd>PgUp</kbd> <span class="sep">/</span> <kbd>PgDn</kbd></td><td>Prev / Next window</td></tr>
      <tr><td><kbd>Prefix</kbd> <kbd>x</kbd></td><td>Kill window</td></tr>
      <tr><td><kbd>Prefix</kbd> <kbd>r</kbd></td><td>Rename window</td></tr>
    </table>

    <div class="sub">Sessions</div>
    <table>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>⇧</kbd> <kbd>Home</kbd></td><td>New session</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>⇧</kbd> <kbd>End</kbd></td><td>Kill session</td></tr>
      <tr><td><kbd>⌃</kbd> <kbd>⌘</kbd> <kbd>⇧</kbd> <kbd>PgUp</kbd> <span class="sep">/</span> <kbd>PgDn</kbd></td><td>Prev / Next session</td></tr>
      <tr><td><kbd>Prefix</kbd> <kbd>R</kbd></td><td>Rename session</td></tr>
      <tr><td><kbd>Prefix</kbd> <kbd>X</kbd></td><td>Kill session</td></tr>
    </table>

    <div class="sub">Copy Mode (Vi)</div>
    <table>
      <tr><td><kbd>v</kbd></td><td>Begin selection</td></tr>
      <tr><td><kbd>y</kbd></td><td>Copy selection</td></tr>
      <tr><td><kbd>Prefix</kbd> <kbd>q</kbd></td><td>Reload config</td></tr>
    </table>
  </div>

</div>

<div class="legend">
  <span><kbd>⌘</kbd> Command</span>
  <span><kbd>⌃</kbd> Control</span>
  <span><kbd>⌥</kbd> Option</span>
  <span><kbd>⇧</kbd> Shift</span>
  <span><kbd>⏎</kbd> Return</span>
</div>

</body>
</html>
HTMLEOF

open "$FILE"
