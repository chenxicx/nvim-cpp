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

function _G.ToggleTerminal()
  -- 检查是否有终端缓冲区存在
  local term_bufnr = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      term_bufnr = buf
      break
    end
  end

  -- 检查当前缓冲区是否为终端
  if vim.bo[vim.api.nvim_get_current_buf()].buftype == "terminal" then
    -- 如果在终端中，则隐藏终端，并尝试切换到上一个窗口
    vim.cmd("hide")
  else
    -- 如果当前不在终端中
    if term_bufnr then
      -- 如果已有终端缓冲区存在
      local term_win_id = vim.fn.bufwinid(term_bufnr)
      if term_win_id ~= -1 and vim.api.nvim_win_is_valid(term_win_id) then
        -- 终端窗口已存在且可见，则切换到该窗口
        vim.api.nvim_set_current_win(term_win_id)
      else
        -- 终端缓冲区存在但隐藏或窗口无效，则在新的底部拆分窗口中打开它
        vim.cmd("botright 15split")
        vim.api.nvim_win_set_buf(0, term_bufnr) -- 将当前新窗口的缓冲区设置为终端缓冲区
      end
      vim.cmd("startinsert") -- 进入终端模式
    else
      -- 如果不存在终端，则创建新终端
      vim.cmd("botright 15split")
      vim.cmd("terminal") -- 在新拆分窗口中打开终端
      vim.cmd("startinsert") -- 进入终端模式
    end
  end
end

-- 添加终端模式下粘贴快捷键 Ctrl+Shift+V
vim.keymap.set("t", "<C-S-v>", "<C-\\><C-N>\"+pi", { noremap = true, silent = true, desc = "从系统剪贴板粘贴" })

-- 添加快捷键将当前搜索结果填充到 Quickfix 列表
vim.keymap.set("n", "<leader>sL", function()
  local last_search = vim.fn.getreg('/')
  if last_search == "" or last_search == vim.NIL then
    vim.notify("没有最近的搜索模式可供列表显示", vim.log.levels.WARN)
    return
  end
  -- 为 vimgrep 转义搜索模式中的 /
  local pattern = vim.fn.substitute(last_search, '/', '\\/', 'g')
  -- 使用 vimgrep 查找匹配项并填充 Quickfix 列表，不自动跳转到第一个匹配 (j flag)
  -- silent! 避免在没有匹配时 vimgrep 可能产生的错误或消息 (尽管通常它只是不填充列表)
  vim.cmd("silent! vimgrep /" .. pattern .. "/gj %")
  -- 获取 Quickfix 列表
  local qf_list = vim.fn.getqflist()
  if #qf_list > 0 then
    vim.cmd("copen") -- 打开 Quickfix 窗口
    vim.notify("搜索结果已填充到 Quickfix 列表 (" .. #qf_list .. " 项)", vim.log.levels.INFO)
  else
    vim.notify("在当前文件中未找到与 '" .. last_search .. "' 匹配的结果", vim.log.levels.INFO)
  end
end, { desc = "用 Quickfix 列表显示当前搜索结果" })

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
