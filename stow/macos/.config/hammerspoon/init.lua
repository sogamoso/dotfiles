local mods = { "cmd", "ctrl" }

hs.hotkey.bind(mods, "right", function()
	hs.window.focusedWindow():focusWindowEast()
end)

hs.hotkey.bind(mods, "left", function()
	hs.window.focusedWindow():focusWindowWest()
end)

hs.hotkey.bind(mods, "up", function()
	hs.window.focusedWindow():focusWindowNorth()
end)

hs.hotkey.bind(mods, "down", function()
	hs.window.focusedWindow():focusWindowSouth()
end)
require("hotkeys")
require("aerospace_follow")

hs.screen.watcher.new(function()
  hs.timer.doAfter(2, function()
    hs.execute("/opt/homebrew/bin/sketchybar --reload")
  end)
end):start()
