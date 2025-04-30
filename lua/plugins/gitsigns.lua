return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true, -- 显示当前行的git blame信息
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 在行尾显示
      delay = 300, -- 显示前的延迟（毫秒）
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  },
  -- 添加自定义键映射
  config = function(_, opts)
    require("gitsigns").setup(opts)
    
    -- 添加切换git blame显示的快捷键
    vim.keymap.set("n", "<leader>gb", function()
      vim.cmd("Gitsigns toggle_current_line_blame")
    end, { desc = "切换行间 Git Blame" })
  end,
}