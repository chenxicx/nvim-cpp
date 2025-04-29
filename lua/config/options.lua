-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.vscode then
    -- VSCode extension
else
    -- 禁用相对行号，只使用绝对行号
    vim.opt.relativenumber = false
    vim.opt.number = true  -- 保留绝对行号
end
