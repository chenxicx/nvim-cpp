return {
  {
    "EthanJWright/vs-tasks.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("vstask").setup({
        -- 配置文件位置，默认会查找 .vscode/tasks.json
        use_all = true, -- 使用所有任务配置文件
        telescope_keys = {
          vertical = "<C-v>", -- 垂直分屏运行任务
          split = "<C-x>",    -- 水平分屏运行任务
          tabs = "<C-t>",     -- 新标签页运行任务
        },
        terminal = "toggleterm", -- 使用 toggleterm 作为终端
        term_opts = {
          vertical = {
            direction = "vertical",
            size = 80,
          },
          horizontal = {
            direction = "horizontal",
            size = 15,
          },
        },
      })
      
      -- 设置快捷键
      vim.keymap.set("n", "<leader>tt", "<cmd>lua require('telescope').extensions.vstask.tasks()<CR>", 
        { desc = "列出可用任务" })
      vim.keymap.set("n", "<leader>tr", "<cmd>lua require('telescope').extensions.vstask.runner()<CR>", 
        { desc = "运行上一个任务" })
      vim.keymap.set("n", "<leader>ti", "<cmd>lua require('telescope').extensions.vstask.inputs()<CR>", 
        { desc = "配置任务输入" })
      vim.keymap.set("n", "<leader>tc", "<cmd>lua require('telescope').extensions.vstask.close()<CR>", 
        { desc = "关闭任务终端" })
    end,
  },
}