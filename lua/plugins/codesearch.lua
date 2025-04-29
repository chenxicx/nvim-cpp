return {
  -- 增强 Telescope 配置，专注于代码搜索功能
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- 搜索代码片段快捷键
      { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "搜索代码片段(全文)" },
      { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "搜索当前单词" },
      { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "搜索文件" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "搜索当前缓冲区" },
      -- 专门针对搜索代码的快捷键
      { "<leader>sc", "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input('搜索代码: ') })<cr>", desc = "输入并搜索代码" },
      { "<leader>sp", "<cmd>Telescope projects<cr>", desc = "搜索项目" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "跳转历史" },
      { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "搜索文档符号" },
      { "<leader>sS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "搜索工作区符号" },
    },
    opts = {
      defaults = {
        -- 改进搜索体验
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.6,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        -- 使用 ripgrep 作为搜索后端
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden", -- 搜索隐藏文件
          "--glob=!.git/", -- 排除 .git 文件夹
        },
      },
      -- 配置文件搜索扩展
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
      -- 针对代码搜索的优化
      pickers = {
        find_files = {
          -- 让文件搜索也能搜索隐藏文件，但排除 .git 目录
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
        live_grep = {
          -- 针对代码搜索的优化
          additional_args = function()
            return { "--hidden", "--glob", "!**/.git/*" }
          end,
        },
      },
    },
  },
  
  -- 可选：添加 fzf-native 以加速搜索
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    enabled = vim.fn.executable("make") == 1,
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  
  -- 可选：项目搜索扩展
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        -- 自动检测项目的根目录规则
        patterns = { ".git", ".svn", "Makefile", "CMakeLists.txt", "package.json" },
        -- 显示项目路径相对于主目录的路径
        show_hidden = true,
      })
      require("telescope").load_extension("projects")
    end,
  },
}