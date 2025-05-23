return
--[[{
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  config = function()
    require("onedarkpro").setup({
      options = {
        transparency = false, -- 如果您需要透明背景，可以设置为 true
      }
    })
    -- 设置主题为 onedark_vivid
    vim.cmd("colorscheme onedark_vivid")
  end,
}]]--
{
  'sharpchen/Eva-Theme.nvim',
  lazy = false,
  priority = 1000,
  --config = function()
  --  vim.cmd("colorscheme Eva-Dark")
  --end,
--  build = ':EvaCompile'
}

