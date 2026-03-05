-- Cycle through windows in the current macOS Space with Cmd+Tab / Cmd+Shift+Tab

local function cycleWorkspaceWindows(reverse)
  -- Get window IDs on the current macOS Space
  local currentSpace = hs.spaces.focusedSpace()
  local spaceWindowIDs = hs.spaces.windowsForSpace(currentSpace) or {}

  local inSpace = {}
  for _, id in ipairs(spaceWindowIDs) do
    inSpace[id] = true
  end

  -- Filter to standard, non-minimized windows on this Space
  local wins = {}
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:isStandard() and not win:isMinimized() and inSpace[win:id()] then
      table.insert(wins, win)
    end
  end

  if #wins < 2 then return end

  local focusedId = hs.window.focusedWindow() and hs.window.focusedWindow():id()
  local currentIdx = 1
  for i, win in ipairs(wins) do
    if win:id() == focusedId then
      currentIdx = i
      break
    end
  end

  local nextIdx
  if reverse then
    nextIdx = (currentIdx - 2) % #wins + 1
  else
    nextIdx = currentIdx % #wins + 1
  end

  _G.aerospaceFollowSuppressed = true
  wins[nextIdx]:focus()
  hs.timer.doAfter(0.2, function() _G.aerospaceFollowSuppressed = false end)
end

hs.hotkey.bind({ "cmd" }, "tab", function()
  cycleWorkspaceWindows(false)
end)

hs.hotkey.bind({ "cmd", "shift" }, "tab", function()
  cycleWorkspaceWindows(true)
end)
