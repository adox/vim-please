-- plugin/please.lua
-- Auto-loads on start and sets up filetype detection + default config.

local M = {}

-- Default config (users can override via require('please').setup{...})
M.cfg = {
  -- filenames to treat as Please BUILD files in addition to BUILD / BUILD.plz
  extra_filenames = {},

  -- extra Please builtins/rules to highlight
  builtins = {
    "filegroup","genrule","gentest",
    "go_binary","go_library","go_test",
    "java_binary","java_library","java_test",
    "python_binary","python_library","python_test",
    "sh_binary","sh_library","sh_test",
    "export_file","remote_file","maven_jar","http_file",
  },

  -- Use Python Tree-sitter for 'please' filetype if available
  use_treesitter_python = true,

  -- Indentation width
  indent = 4,
}

function M.setup(opts)
  M.cfg = vim.tbl_deep_extend("force", M.cfg, opts or {})
end

-- 1) Filetype detection (BUILD, BUILD.plz, + user extras)
vim.filetype.add({
  pattern = {
    [".*/BUILD$"] = "please",
    [".*/BUILD%.plz$"] = "please",
  }
})

-- Also detect by bare filename for users opening from cwd
vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  pattern = { "BUILD", "BUILD.plz" },
  callback = function() vim.bo.filetype = "please" end,
})

-- User-defined extra filenames
vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  pattern = "*",
  callback = function()
    local name = vim.fn.expand("%:t")
    for _,fn in ipairs(M.cfg.extra_filenames or {}) do
      if name == fn then
        vim.bo.filetype = "please"
        break
      end
    end
  end,
})

-- 2) Tree-sitter mapping: tell TS to use python parser for 'please'
-- Works on Neovim 0.9+ (language.register). Guard in pcall for older versions.
local function register_ts()
  if M.cfg.use_treesitter_python then
    local ok, ts = pcall(require, "vim.treesitter")
    if ok and ts.language and ts.language.register then
      pcall(ts.language.register, "python", "please") -- use python grammar
    end
  end
end
register_ts()

-- 3) Syntax + indent setup when ft=please
vim.api.nvim_create_autocmd("FileType", {
  pattern = "please",
  callback = function(args)
    local bufnr = args.buf

    -- Indentation: reuse Python indent logic
    vim.schedule(function()
      vim.cmd("runtime! indent/python.vim")
      vim.bo[bufnr].shiftwidth  = M.cfg.indent
      vim.bo[bufnr].softtabstop = M.cfg.indent
      vim.bo[bufnr].tabstop     = M.cfg.indent
      vim.bo[bufnr].expandtab   = true
    end)

    -- Base syntax on Python then add Please tokens
    vim.schedule(function()
      vim.cmd("runtime! syntax/python.vim")

      -- Keyword group for rule names / builtins
      local kws = table.concat(M.cfg.builtins, " ")
      if #kws > 0 then
        vim.cmd(("syntax keyword pleaseBuiltin %s"):format(kws))
        vim.cmd("highlight default link pleaseBuiltin Function")
      end

      -- Labels: //pkg:target and :local_target
      vim.cmd([[syntax match pleaseLabel /\/\/\%(\w\|[\/\.\-\+]\)\+:\%(\w\|[\/\.\-\+]\)\+/]])
      vim.cmd([[syntax match pleaseLabel /:\%(\w\|[\/\.\-\+]\)\+/]])
      vim.cmd([[highlight default link pleaseLabel Constant]])

      -- Common attr keywords
      vim.cmd([[syntax keyword pleaseKw visibility deps srcs outs testonly tools select package_name glob includes]])
      vim.cmd([[highlight default link pleaseKw Keyword]])

      -- Comments are Python-style already; ensure commentstring
      vim.bo[bufnr].commentstring = "# %s"
      -- Folding by indent is sane for BUILD files
      vim.bo[bufnr].foldmethod = "indent"
    end)
  end,
})

-- Expose setup()
_G.__please_cfg = M
return M

