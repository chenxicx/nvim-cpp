return
{
  "chenxicx/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  config = function()
    vim.cmd("colorscheme catppuccin-mocha") -- 设置默认主题为 catppuccin-macchiato
    --[[require("onedarkpro").setup({
      options = {
        transparency = false, -- 如果您需要透明背景，可以设置为 true
      }
    })]]--
  end,
}
--[[{
  'sharpchen/Eva-Theme.nvim',
  lazy = false,
  priority = 1000,
  --config = function()
  --  vim.cmd("colorscheme Eva-Dark")
  --end,
--  build = ':EvaCompile'
}]]--

