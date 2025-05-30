-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_augroup("LogFileHighlights", { clear = true })

-- let jj exit inert mode
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.log",
  group = "LogFileHighlights",
  callback = function()
    -- 关于高亮范围的说明：
    -- 1. `vim.fn.matchadd` 定义的高亮规则会应用于当前窗口的整个缓冲区。
    -- 2. Neovim 的显示引擎仅渲染（绘制）屏幕上当前可见部分的高亮。
    --    这意味着即使规则应用于整个缓冲区，实际的绘制开销仅限于可见区域。
    -- 3. 如果主要担忧的是在超大文件中模式匹配本身的性能（而非渲染），
    --    `matchadd` 仍可能检查超出可见区域的文本。
    --    要将匹配过程也严格限制于可见行，需要更复杂的方案（如监听滚动事件并使用 `matchaddpos`）。
    --    当前配置为简洁起见，依赖 Neovim 的默认行为。

    vim.api.nvim_set_hl(0, "LogAwayFromRestriction", { bg = "#83A598" }) -- blue background
    vim.fn.matchadd("LogAwayFromRestriction", [[.*away_from_restriction_area.*]])

    vim.api.nvim_set_hl(0, "LogTaskFindMapBoundary", { bg = "#43Ff98" }) -- blue background
    vim.fn.matchadd("LogTaskFindMapBoundary", [[.*task_find_map_boundary.*]])

    vim.api.nvim_set_hl(0, "Log_requestNewGlobalCostmap", { bg = "#0055AF" }) -- blue background
    vim.fn.matchadd("Log_requestNewGlobalCostmap", [[.*requestNewGlobalCostmap.*]])

    vim.api.nvim_set_hl(0, "Log_navigation_task_go_out_restriction_area", { bg = "#30A5AF" }) -- blue background
    vim.fn.matchadd("Log_navigation_task_go_out_restriction_area", [[.*navigation_task_go_out_restriction_area.*]])

    vim.api.nvim_set_hl(0, "Log_requestSyncedGlobalMapAndOdom", { bg = "#1045AF" }) -- blue background
    vim.fn.matchadd("Log_requestSyncedGlobalMapAndOdom", [[.*requestSyncedGlobalMapAndOdom.*]])
  end,
})
