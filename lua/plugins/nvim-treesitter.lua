return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = { "cpp" },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      fold = {
        enable = true,
      },
    }
    vim.opt.foldmethod = "manual"
  end
}