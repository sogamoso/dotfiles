local mods = { "cmd", "ctrl" }
local cheatsheet = nil

hs.hotkey.bind(mods, "/", function()
  if cheatsheet and cheatsheet:isVisible() then
    cheatsheet:hide()
    return
  end

  local f = hs.screen.mainScreen():frame()
  local w, h = 960, 720
  local x = (f.w - w) / 2 + f.x
  local y = (f.h - h) / 2 + f.y

  if not cheatsheet then
    cheatsheet = hs.webview.new({ x = x, y = y, w = w, h = h })
    cheatsheet:windowStyle({ "titled", "closable", "resizable" })
    cheatsheet:windowTitle("Hotkeys")
    cheatsheet:url("http://localhost:8765")
  end

  cheatsheet:show()
  cheatsheet:bringToFront()
end)
