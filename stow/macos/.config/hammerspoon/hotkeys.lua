local hotMods = { "cmd", "ctrl" }
local cheatsheet = nil
local keyTap = nil

local function close()
  if keyTap then keyTap:stop(); keyTap = nil end
  if cheatsheet then local cs = cheatsheet; cheatsheet = nil; cs:delete() end
end

hs.hotkey.bind(hotMods, "/", function()
  if cheatsheet then close(); return end

  local f = hs.screen.mainScreen():frame()
  local w, h = 960, 720

  cheatsheet = hs.webview.new({
    x = (f.w - w) / 2 + f.x,
    y = (f.h - h) / 2 + f.y,
    w = w, h = h,
  })
  cheatsheet:windowStyle({ "titled", "closable", "resizable" })
  cheatsheet:windowTitle("Hotkeys")
  local path = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/.config/hotkeys/index.html")
  cheatsheet:url("file://" .. path)

  cheatsheet:windowCallback(function(action)
    if action == "closing" then
      if keyTap then keyTap:stop(); keyTap = nil end
      cheatsheet = nil
    end
  end)

  keyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    local code = e:getKeyCode()
    local flags = e:getFlags()
    if code == hs.keycodes.map["escape"] then close(); return true end
    if flags.cmd and code == hs.keycodes.map["w"] then close(); return true end
    if flags.cmd and code == hs.keycodes.map["q"] then close(); return true end
    if code == hs.keycodes.map["up"] then
      cheatsheet:evaluateJavaScript("window.scrollBy(0, -120)"); return true
    end
    if code == hs.keycodes.map["down"] then
      cheatsheet:evaluateJavaScript("window.scrollBy(0, 120)"); return true
    end
    if code == hs.keycodes.map["pageup"] then
      cheatsheet:evaluateJavaScript("window.scrollBy(0, -600)"); return true
    end
    if code == hs.keycodes.map["pagedown"] then
      cheatsheet:evaluateJavaScript("window.scrollBy(0, 600)"); return true
    end
  end)

  cheatsheet:show()
  cheatsheet:bringToFront()
  keyTap:start()
end)
