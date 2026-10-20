-- Colorscheme follows the active theme (`theme set <name>`, see bin/theme):
-- ~/.config/theme/current/nvim.lua returns a colorscheme name. Every theme's
-- plugin is listed here (lazy-loaded, so only the active one loads), all set
-- transparent so Ghostty's background shows through.

local theme_file = vim.fn.expand("~/.config/theme/current/nvim.lua")
local applied

local function theme_colorscheme()
  local ok, name = pcall(dofile, theme_file)
  if ok and type(name) == "string" and name ~= "" then
    return name
  end
  return "tokyonight-night"
end

local function apply()
  local name = theme_colorscheme()
  if name ~= applied and pcall(vim.cmd.colorscheme, name) then
    applied = name
  end
end

return {
  { "folke/tokyonight.nvim", lazy = true, opts = { style = "night", transparent = true } },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        neotree = true,
        treesitter = true,
        telescope = true,
        which_key = true,
        native_lsp = { enabled = true },
      },
    },
  },
  { "ellisonleao/gruvbox.nvim", lazy = true, opts = { transparent_mode = true } },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, opts = { styles = { transparency = true } } },
  { "gbprod/nord.nvim", lazy = true, opts = { transparent = true } },
  { "neanias/everforest-nvim", main = "everforest", lazy = true, opts = { transparent_background_level = 1 } },
  { "rebelot/kanagawa.nvim", lazy = true, opts = { transparent = true } },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = apply },
    init = function()
      -- Pick up `theme set` in already-open Neovims when you switch back to them.
      vim.api.nvim_create_autocmd("FocusGained", { callback = apply })
    end,
  },
}
