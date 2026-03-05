-- Follow app to its AeroSpace workspace on activation (e.g. Cmd+Tab)
local appWorkspaces = {
  -- 1: Browsing
  ["com.google.Chrome"]    = "1",
  ["com.apple.Safari"]     = "1",
  -- 2: Programming
  ["com.mitchellh.ghostty"]  = "2",
  ["io.alacritty"]            = "2",
  ["com.soloterm.solo"]       = "2",
  ["dev.zed.Zed"]             = "2",
  ["com.linear"]              = "2",
  ["com.google.Chrome.app.mjoklplbddabcmpepnokjaffbmgbkkgg"] = "2",
  ["com.tinyapp.TablePlus"]   = "2",
  -- 3: Communication
  ["com.tinyspeck.slackmacgap"]  = "3",
  ["com.google.Chrome.app.kjgfgldnnfoeklkmfkjfagphfepbbdan"] = "3",
  ["net.whatsapp.WhatsApp"]       = "3",
  ["com.hnc.Discord"]             = "3",
  -- 4: Scheduling
  ["com.hey.app.desktop"]  = "4",
  ["com.google.Chrome.app.fmgjjmmmlfnkbppncabfkddbjimcfncm"] = "4",
  ["com.google.Chrome.app.kjbdgfilnfhdoflbpgamdcdgpehopbep"] = "4",
  -- 5: Writing
  ["abnerworks.Typora"]    = "5",
  ["md.obsidian"]          = "5",
  ["notion.id"]            = "5",
  ["com.apple.Notes"]      = "5",
  -- 6: AI Tools
  ["com.openai.chat"]                  = "6",
  ["com.anthropic.claudefordesktop"]   = "6",
  ["com.openai.codex"]                 = "6",
  -- 7: Entertainment
  ["com.spotify.client"]  = "7",
  ["com.google.Chrome.app.agimnkijcaahngcdmfeangaknmldooml"] = "7",
  ["com.apple.Music"]     = "7",
}

local appWatcher = hs.application.watcher.new(function(name, event, app)
  if event ~= hs.application.watcher.activated then return end
  if _G.aerospaceFollowSuppressed then return end
  local bundleID = app:bundleID()
  local workspace = appWorkspaces[bundleID]
  if not workspace then return end

  hs.task.new("/opt/homebrew/bin/aerospace", nil, {"workspace", workspace}):start()
  hs.task.new("/opt/homebrew/bin/sketchybar", nil,
    {"--trigger", "aerospace_workspace_change", "FOCUSED_WORKSPACE=" .. workspace}):start()
end)

appWatcher:start()
