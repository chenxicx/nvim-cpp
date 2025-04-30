-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.g.vscode then
  return true
end

-- 添加格式化选中代码的快捷键
vim.keymap.set("v", "<leader>cf", function()
  local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
  
  -- 调用 conform.nvim 的格式化功能，仅针对选中行
  require("conform").format({
    range = {
      start = { start_row, 0 },
      ["end"] = { end_row, 0 },
    },
    async = true,
    lsp_fallback = true,
  })
end, { desc = "格式化选中代码" })

-- 备用快捷键 - 通过 gq 也可以格式化选中代码
vim.keymap.set("v", "gq", function()
  local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
  
  require("conform").format({
    range = {
      start = { start_row, 0 },
      ["end"] = { end_row, 0 },
    },
    async = true,
    lsp_fallback = true,
  })
end, { desc = "格式化选中代码 (gq)" })
