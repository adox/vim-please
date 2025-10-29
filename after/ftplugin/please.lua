-- after/ftplugin/please.lua
-- These run after the filetype is set; safe to tweak buffer options here.

-- Keep lines as-is; BUILD files often exceed 80 cols
vim.bo.textwidth = 0

-- Sensible completion (identifiers, file paths)
vim.opt_local.iskeyword:append("_")

-- Optional: align arguments when you press '=' (works with python indentexpr)
-- Users can override in their own ftplugin if they prefer
