-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_augroup("LogFileHighlights", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.log",
  group = "LogFileHighlights",
  callback = function()
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
