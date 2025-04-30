return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    -- 默认配置，您可以根据需要调整
    position = "bottom", -- 在底部显示
    height = 10, -- 高度为10行
    icons = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
      fold_open = "", -- 图标：打开的文件夹
      fold_closed = "", -- 图标：关闭的文件夹
    },
    mode = "workspace_diagnostics", -- 默认模式为工作区诊断
    group = true, -- 按文件分组
    padding = true, -- 添加额外的填充
    action_keys = {
      -- 自定义按键，这些是默认值
      close = "q", -- 关闭trouble窗口
      cancel = "<esc>", -- 取消
      refresh = "r", -- 刷新
      jump = { "<cr>", "<tab>" }, -- 跳转到问题
      open_split = { "<c-x>" }, -- 在分割窗口中打开
      open_vsplit = { "<c-v>" }, -- 在垂直分割窗口中打开
      open_tab = { "<c-t>" }, -- 在新标签页中打开
      jump_close = { "o" }, -- 跳转并关闭
      toggle_mode = "m", -- 切换模式
      toggle_preview = "P", -- 预览
      hover = "K", -- 查看诊断信息
      preview = "p", -- 预览位置
      close_folds = { "zM", "zm" }, -- 关闭所有折叠
      open_folds = { "zR", "zr" }, -- 打开所有折叠
      toggle_fold = { "zA", "za" }, -- 切换折叠
      previous = "k", -- 上一个条目
      next = "j", -- 下一个条目
    },
    auto_jump = {},
    use_diagnostic_signs = true,
  },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "打开Trouble" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "工作区诊断" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "文档诊断" },
    { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP引用" },
    { "gR", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "显示引用" },
    { "[q", function() require("trouble").previous({skip_groups = true, jump = true}) end, desc = "上一个问题" },
    { "]q", function() require("trouble").next({skip_groups = true, jump = true}) end, desc = "下一个问题" },
  },
}