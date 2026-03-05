-- Reload sketchybar when screens change
hs.screen.watcher.new(function()
  hs.timer.doAfter(2, function()
    hs.execute("/opt/homebrew/bin/sketchybar --reload")
  end)
end):start()
