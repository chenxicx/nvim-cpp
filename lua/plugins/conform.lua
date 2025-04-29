return {
  "stevearc/conform.nvim",
  opts = {
    -- 禁用保存时自动格式化
    format_on_save = {
      enabled = false,
      timeout_ms = 500,
    },

    -- 启用编辑时自动格式化代码片段
    format_after_edit = {
      enabled = true,
      -- 最少需要更改4个字符才会触发格式化
      minimum_changes = 4,
      -- 编辑后多少毫秒后开始格式化
      timeout_ms = 500,
      -- 哪些文件类型支持编辑时自动格式化
      lsp_fallback = true,
    },

    -- 保留默认的格式化程序设置
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      cpp = { "clang_format" },
      c = { "clang_format" },
      cmake = { "cmake_format" },
      json = { "jq" },
      markdown = { "prettier" },
    },
  },
}