-- Send every plain yank to the terminal's clipboard over OSC 52, so a `y` in
-- Neovim on the Mac mini reaches the clipboard of the device connected over
-- SSH or mosh (Blink on the phone, Ghostty on the laptop).
--
-- LazyVim leaves 'clipboard' empty in SSH sessions so "+y goes out over OSC 52,
-- but then a plain y never leaves Neovim. Omarchy fixed the same thing with a
-- remote clipboard provider (basecamp/omarchy 7270ee5) whose source isn't
-- public, so this is our own. It runs on every yank rather than only under SSH:
-- herdr panes don't inherit the SSH session's environment, so an SSH check
-- would miss the usual case, and locally OSC 52 lands in the same clipboard
-- Neovim already copies to.

local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
if not ok then
  return
end
local copy = osc52.copy("+")

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("osc52_yank", { clear = true }),
  callback = function()
    local event = vim.v.event
    if event.operator == "y" and event.regname == "" then
      pcall(copy, event.regcontents)
    end
  end,
})
