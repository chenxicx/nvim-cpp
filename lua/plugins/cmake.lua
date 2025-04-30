return {
  {
    "Civitasv/cmake-tools.nvim",
    lazy = false,
    config = function()
      require("cmake-tools").setup {}
      
      --运行CMakeSettings设置
      
      -- CMake 快捷键设置
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- CMake 核心命令的快捷键
      keymap("n", "<leader>ccg", "<cmd>CMakeGenerate<CR>", { desc = "生成 CMake 配置", unpack(opts) })
      keymap("n", "<leader>ccb", "<cmd>CMakeBuild<CR>", { desc = "构建 CMake 项目", unpack(opts) })
      keymap("n", "<leader>ccr", "<cmd>CMakeRun<CR>", { desc = "运行 CMake 项目", unpack(opts) })
      keymap("n", "<leader>ccd", "<cmd>CMakeDebug<CR>", { desc = "调试 CMake 项目", unpack(opts) })
      keymap("n", "<leader>ccc", "<cmd>CMakeClean<CR>", { desc = "清理 CMake 构建", unpack(opts) })
      keymap("n", "<leader>ccx", "<cmd>CMakeClose<CR>", { desc = "关闭 CMake", unpack(opts) })

      -- CMake 更多操作
      keymap("n", "<leader>ccs", "<cmd>CMakeSelectBuildType<CR>", { desc = "选择构建类型", unpack(opts) })
      keymap("n", "<leader>cct", "<cmd>CMakeSelectBuildTarget<CR>", { desc = "选择构建目标", unpack(opts) })
      keymap("n", "<leader>ccl", "<cmd>CMakeSelectLaunchTarget<CR>", { desc = "选择运行目标", unpack(opts) })
      keymap("n", "<leader>cco", "<cmd>copen<CR>", { desc = "打开 CMake 控制台", unpack(opts) })
      keymap("n", "<leader>cci", "<cmd>CMakeInstall<CR>", { desc = "安装 CMake 项目", unpack(opts) })
    end
  }
}