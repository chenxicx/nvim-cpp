-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.vscode then
    -- VSCode extension
else
    -- 禁用相对行号，只使用绝对行号
    vim.opt.relativenumber = false
    vim.opt.number = true  -- 保留绝对行号
    
    -- 如果运行的是Neovide，设置特定的字体大小和行间距
    if vim.g.neovide then
        -- 设置字体大小为14
        vim.o.guifont = "JetBrainsMono Nerd Font:h18" -- text below applies for VimScript
        -- 设置行间距为1.2
        vim.opt.linespace = 6
        -- 禁用鼠标动画
        vim.g.neovide_cursor_animation_length = 0
        -- 高亮当前行
        vim.opt.cursorline = true
    end
    
    -- 设置当前行高亮颜色为浅灰色
    vim.opt.cursorline = true
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            -- 设置当前行高亮为浅灰色背景
            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#505050" })
        end,
    })
    -- 立即应用高亮设置
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#505050" })
end
