-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.vscode then
    -- VSCode extension
    -- 设置编码为utf-8，避免中文显示问题
    vim.opt.encoding = "utf-8"
    vim.opt.fileencoding = "utf-8"
    
    -- 禁用VSCode中的Neovim语法检查，避免中文被标记为问题
    vim.opt.spell = false
    
    -- 防止中文字符被识别为语法错误
    vim.g.loaded_matchparen = 1
    vim.g.loaded_syntax_completion = 1
else
    -- 禁用相对行号，只使用绝对行号
    vim.opt.relativenumber = false
    vim.opt.number = true  -- 保留绝对行号

    -- 如果运行的是Neovide，设置特定的字体大小和行间距
    if vim.g.neovide then
        -- 设置字体大小为14
        vim.o.guifont = "JetBrainsMono Nerd Font:h18" -- text below applies for VimScript
        -- 设置行间距为1.2
        vim.opt.linespace = 10
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

    -- format
    vim.g.autoformat = false
    vim.g.autoformat_on_save = true
    vim.g.inlay_hints = false

    -- 允许命令行模式使用系统剪贴板
    -- 设置 Ctrl+v 在命令行模式下粘贴系统剪贴板内容
    vim.keymap.set("c", "<C-v>", "<C-r>+", { desc = "粘贴系统剪贴板内容" })
    -- 设置 Ctrl+Shift+v 在命令行模式下粘贴系统剪贴板内容（某些终端可能需要这个）
    vim.keymap.set("c", "<C-S-v>", "<C-r>+", { desc = "粘贴系统剪贴板内容" })

    -- C++代码缩进设置为4个空格
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cpp", "c", "h", "hpp" },
        callback = function()
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
            vim.bo.expandtab = true
            vim.bo.softtabstop = 4
        end,
    })

    -- 配置自动缩进
    vim.opt.autoindent = true  -- 启用自动缩进
    vim.opt.smartindent = true -- 智能缩进
    vim.opt.cindent = true     -- C语言风格缩进

    -- 确保新行匹配当前行缩进
    vim.opt.copyindent = true  -- 复制前一行的缩进
    vim.opt.preserveindent = true -- 尽可能保留现有的缩进结构

    -- 设置缩进选项，对所有文件类型生效
    vim.opt.expandtab = true   -- 使用空格代替Tab
    vim.opt.shiftwidth = 4     -- 默认缩进空格数
    vim.opt.tabstop = 4        -- 显示Tab字符的宽度
    vim.opt.softtabstop = 4    -- 编辑时Tab键宽度
end

-- 禁用官方 Copilot 插件，避免与 zbirenbaum/copilot.lua 冲突
vim.g.copilot_no_tab_map = true
vim.g.copilot_enabled = false
vim.g.copilot_assume_mapped = true
vim.opt.termguicolors = true

vim.opt.foldmethod = "manual"
