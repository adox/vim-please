# vim-please

A lightweight **Neovim plugin** (written in Lua) that provides:
- Filetype detection for [Please build system](https://please.build) `BUILD` files  
- Syntax highlighting for Please rules, labels, and attributes  
- Python-style indentation (since Please BUILD is a Pythonic DSL)  
- Optional Tree-sitter support (uses the Python parser for `please` files)  

---

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ 'adox/vim-please' }
```
---

## Configuration

Optional setup function — call it from your `init.lua`:

```lua
require('please').setup({
  -- Additional filenames to detect
  extra_filenames = { 'BUILD.myorg', 'BUILD.bzl' },

  -- Use Python Tree-sitter parser for better syntax
  use_treesitter_python = true,

  -- Indentation width
  indent = 4,
})
```

All options are optional — defaults are sane.

---

## Usage

Once installed, open a file named `BUILD`, `BUILD.plz`, or any filename you’ve configured.
You’ll automatically get:

- Filetype: `please`
- Python-style indentation and comments
- Please-specific syntax highlighting

You can check filetype detection with:

```vim
:set ft?
```

It should print:
```
filetype=please
```

---

## Tree-sitter Support

Please BUILD files are Python-like.  
This plugin registers the `please` filetype to reuse the **Python Tree-sitter parser**.

Make sure the Python grammar is installed:
```vim
:TSInstall python
```

Then check it’s active:
```vim
:TSModuleInfo
```

---

## Future ideas

- Add `:PlzBuild`, `:PlzTest`, and `:PlzRun` commands (with async jobs + quickfix integration)
- Auto-detect Please workspace root via `.plzconfig`
- Native Tree-sitter grammar for `please.build` DSL

---

### Contributions
Pull requests and issues are welcome!  
If you work with Please at scale and want better Neovim integration (build/test commands, LSP-like behavior), open an issue or PR.

---

## License

MIT License © 2025
