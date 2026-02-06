# Persist history across sessions
IRB.conf[:SAVE_HISTORY] = 2000
IRB.conf[:HISTORY_FILE] = File.expand_path("~/.irb_history")
