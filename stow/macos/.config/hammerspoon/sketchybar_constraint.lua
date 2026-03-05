-- Constrain windows to stay below sketchybar on the main screen

local function sketchybarHeight()
  local output = hs.execute("/opt/homebrew/bin/sketchybar --query bar 2>/dev/null")
  local h = output:match('"height":(%d+)')
  return tonumber(h) or 30
end

local function constrainToBar(win)
  if not win or not win:isStandard() then return end
  local screen = win:screen()
  if not screen or screen ~= hs.screen.mainScreen() then return end
  -- visibleFrame already excludes native menu bar; add sketchybar height on top
  local topBound = screen:visibleFrame().y + sketchybarHeight()
  local frame = win:frame()
  if frame.y < topBound then
    frame.h = math.max(100, frame.h - (topBound - frame.y))
    frame.y = topBound
    win:setFrame(frame, 0)
  end
end

hs.window.filter.new()
  :subscribe(hs.window.filter.windowCreated, function(win)
    hs.timer.doAfter(0.3, function() constrainToBar(win) end)
  end)
