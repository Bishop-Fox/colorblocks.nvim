# colorblocks.nvim

> A minimal Neovim plugin to display color preview blocks next to hex codes like `#FF0000`.

## ✨ Features

- 🎨 Highlights hex codes with colored virtual `■` blocks
- 🔍 Matches `#RRGGBB` hex color patterns
- 🛠 Togglable with commands
- 🧠 Minimal and fast — no dependencies

## 📦 Installation (with lazy.nvim)

```lua
{
  dir = "~/Development/colorblocks.nvim",
  name = "colorblocks",
  config = function()
    require("colorblocks").setup()
  end
}
```

## ⚙️ Usage

By default, it matches `#RRGGBB` format in any file and shows a colored block and comment after it:

```lua
local red = "#FF0000"  -- 🟥 #FF0000
```

## 🔧 Commands

- `:ColorBlocksToggle` — toggle visibility on/off
- `:ColorBlocksEnable` — turn on highlights
- `:ColorBlocksDisable` — clear extmarks

## 🧪 Testing

Try running from the `dev/` directory:

```lua
vim.opt.rtp:prepend(".")
require("colorblocks").setup()
```

## 📁 Project Layout

```
colorblocks.nvim/
├── lua/colorblocks/init.lua      → plugin entrypoint
├── lua/colorblocks/core.lua      → highlight logic
├── dev/init.lua                  → test loader
├── examples/sample.lua           → example file with colors
├── tests/                        → placeholder for future tests
├── docs/                         → optional Vim help
├── stylua.toml                   → formatting config
├── .gitignore                    → git hygiene
└── .github/workflows/test.yml    → CI stub
```

## 📄 License

MIT © You
