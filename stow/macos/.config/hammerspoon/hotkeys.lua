local hotMods = { "cmd", "ctrl" }

-- Window focus by direction
hs.hotkey.bind(hotMods, "right", function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind(hotMods, "left",  function() hs.window.focusedWindow():focusWindowWest() end)
hs.hotkey.bind(hotMods, "up",    function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(hotMods, "down",  function() hs.window.focusedWindow():focusWindowSouth() end)
