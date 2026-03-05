-- Cycle through windows in the current AeroSpace workspace with Cmd+Tab / Cmd+Shift+Tab

local function cycleWorkspaceWindows(reverse)
  local output = hs.execute("/opt/homebrew/bin/aerospace list-windows --workspace focused --format '%{window-id}' 2>/dev/null")

  local ids = {}
  for id in output:gmatch("%d+") do
    table.insert(ids, tonumber(id))
  end

  if #ids < 2 then return end

  local focusedId = hs.window.focusedWindow() and hs.window.focusedWindow():id()

  local currentIdx = 1
  for i, id in ipairs(ids) do
    if id == focusedId then
      currentIdx = i
      break
    end
  end

  local nextIdx
  if reverse then
    nextIdx = (currentIdx - 2) % #ids + 1
  else
    nextIdx = currentIdx % #ids + 1
  end

  hs.execute("/opt/homebrew/bin/aerospace focus --window-id " .. ids[nextIdx] .. " 2>/dev/null")
end

local workspaceSwitcherNext = hs.hotkey.bind({ "cmd" }, "tab", function()
  cycleWorkspaceWindows(false)
end)

local workspaceSwitcherPrev = hs.hotkey.bind({ "cmd", "shift" }, "tab", function()
  cycleWorkspaceWindows(true)
end)
