-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- No shada file. ~/.local/state/nvim/shada/main.shada is neovim's own
-- recent-files record: the jumplist, file marks, :oldfiles, plus command and
-- search history -- i.e. the paths of everything ever edited, kept indefinitely.
-- "NONE" disables both reading and writing; setting shada="" only empties the
-- option list and neovim still touches the file.
--
-- COST, and it is real: no `"` mark, so reopening a file no longer restores the
-- cursor position; :oldfiles and telescope's oldfiles picker come back empty;
-- command and search history do not survive quitting. Undo history is separate
-- (undofile) and unaffected.
vim.opt.shadafile = "NONE"
