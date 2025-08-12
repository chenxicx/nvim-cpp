return {
  -- 针对VSCode中的Neovim插件配置
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- 只在VSCode模式下应用这些配置
      if vim.g.vscode then
        -- 禁用所有与语法检查相关的插件，避免中文被标记为错误
        opts.lsp = opts.lsp or {}
        opts.lsp.enabled = false -- 禁用LSP以避免干扰VSCode的语言服务

        -- 禁用拼写检查
        vim.opt.spell = false
        vim.opt.spelllang = {}
      end
    end,
  },
  -- 如果使用了treesitter，确保它在VSCode中不干扰中文输入
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if vim.g.vscode then
        -- 在VSCode模式下禁用treesitter的高亮功能
        opts.highlight = opts.highlight or {}
        opts.highlight.enable = false
      end
    end,
  },
}
