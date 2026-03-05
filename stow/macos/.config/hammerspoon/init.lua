require("hotkeys")
require("cheatsheet")
require("aerospace_follow")

hs.screen.watcher
	.new(function()
		hs.timer.doAfter(2, function()
			hs.execute("/opt/homebrew/bin/sketchybar --reload")
		end)
	end)
	:start()
