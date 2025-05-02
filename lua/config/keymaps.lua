-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.g.vscode then
  return true
end

-- 添加lazygit快捷键
vim.keymap.set("n", "<leader>gg", function()
  vim.cmd("term lazygit")
end, { desc = "打开 lazygit" })

-- 配置Ctrl+`打开终端，再次按下则折叠终端
vim.api.nvim_set_keymap("n", [[<C-\>]], [[:lua ToggleTerminal()<CR>]], { noremap = true, silent = true, desc = "打开/折叠终端" })
vim.api.nvim_set_keymap("t", [[<C-\>]], [[<C-\><C-n>:lua ToggleTerminal()<CR>]], { noremap = true, silent = true, desc = "打开/折叠终端" })

-- 定义终端切换函数
function _G.ToggleTerminal()
  -- 检查是否有终端缓冲区存在
  local terminal_bufnr = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      terminal_bufnr = buf
      break
    end
  end
  
  -- 检查当前缓冲区是否为终端
  if vim.bo.buftype == "terminal" then
    -- 如果在终端中，则隐藏终端
    vim.cmd("hide")
  else
    if terminal_bufnr then
      -- 如果已有终端，则显示它
      vim.cmd("botright 15sp")
      vim.api.nvim_set_current_buf(terminal_bufnr)
      vim.cmd("startinsert")
    else
      -- 如果不存在终端，则创建新终端
      vim.cmd("botright 15sp | term")
      vim.cmd("startinsert")
    end
  end
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
