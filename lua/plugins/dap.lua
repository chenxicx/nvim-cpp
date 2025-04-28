return {
  -- 核心DAP插件
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI 界面
      { "rcarriga/nvim-dap-ui" },
      -- 调试过程中的虚拟文本
      { "theHamsta/nvim-dap-virtual-text" },
      -- Mason集成
      { "jay-babu/mason-nvim-dap.nvim" },
      -- C/C++ 调试适配器
      { "williamboman/mason.nvim" },
      -- 确保依赖cmake-tools
      { "Civitasv/cmake-tools.nvim" },
    },
    keys = {
      -- 调试操作快捷键
      { "<F5>", function() 
        -- 智能启动：优先使用CMake目标
        require("plugins.utils.cmake_dap_launcher").smart_launch()
      end, desc = "调试: 智能启动" },
      { "<F10>", function() require("dap").step_over() end, desc = "调试: 单步跳过" },
      { "<F11>", function() require("dap").step_into() end, desc = "调试: 单步进入" },
      { "<F12>", function() require("dap").step_out() end, desc = "调试: 单步跳出" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "调试: 切换断点" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "调试: 条件断点" },
      { "<leader>dc", function() 
        -- 智能启动：优先使用CMake目标
        require("plugins.utils.cmake_dap_launcher").smart_launch()
      end, desc = "调试: 智能启动" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "调试: 运行到光标处" },
      { "<leader>di", function() require("dap").step_into() end, desc = "调试: 单步进入" },
      { "<leader>do", function() require("dap").step_over() end, desc = "调试: 单步跳过" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "调试: 单步跳出" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "调试: 终止" },
      { "<leader>dp", function() require("dap").pause() end, desc = "调试: 暂停" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "调试: 切换REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "调试: 运行上次" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "调试: 切换UI" },
    },
    config = function()
      local dap = require("dap")
      
      -- 配置C/C++调试器
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }

      -- 配置C/C++调试启动配置
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = true,
          setupCommands = {
            {
              text = '-enable-pretty-printing',
              description = 'enable pretty printing',
              ignoreFailures = false
            },
          },
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'cppdbg',
          request = 'launch',
          MIMode = 'gdb',
          miDebuggerServerAddress = 'localhost:1234',
          miDebuggerPath = '/usr/bin/gdb',
          cwd = '${workspaceFolder}',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          setupCommands = {
            {
              text = '-enable-pretty-printing',
              description = 'enable pretty printing',
              ignoreFailures = false
            },
          },
        },
      }
      
      -- 为C语言复制相同的配置
      dap.configurations.c = dap.configurations.cpp
      
      -- 设置图标
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticSignInfo", linehl = "CursorLine", numhl = "" })
    end,
  },
  
  -- DAP UI配置
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      icons = { expanded = "▾", collapsed = "▸" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10,
          position = "bottom",
        }
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
    },
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(opts)
      
      -- 自动打开和关闭UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },
  
  -- DAP虚拟文本
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      virt_text_pos = 'eol',
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil
    },
  },
  
  -- Mason DAP集成
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "cpptools" },
      automatic_installation = true,
      handlers = {},
    },
  }
}