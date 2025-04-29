return {
  "stevearc/overseer.nvim",
  opts = function(_, opts)
    -- 保留原始配置
    opts = opts or {}
    opts.task_list = opts.task_list or {}
    
    -- 获取配置文件路径函数
    local function get_config_path()
      -- 使用当前工作目录下的.nvim/cmake_args.json
      local cwd = vim.fn.getcwd()
      local config_dir = cwd .. "/.nvim"
      local config_file = config_dir .. "/cmake_args.json"
      
      -- 确保目录存在
      if vim.fn.isdirectory(config_dir) == 0 then
        vim.fn.mkdir(config_dir, "p")
      end
      
      return config_file
    end
    
    -- 从配置文件中读取参数的函数
    local function read_config(config_path, target_name)
      local config = {}
      local args = {}
      
      if vim.fn.filereadable(config_path) == 1 then
        local file = io.open(config_path, "r")
        if file then
          local content = file:read("*a")
          file:close()
          
          local success, decoded = pcall(vim.json.decode, content)
          if success and decoded then
            config = decoded
            if config[target_name] then
              args = config[target_name]
            end
          end
        end
      end
      
      return config, args
    end
    
    -- 将参数写入配置文件的函数
    local function write_config(config_path, config)
      local file = io.open(config_path, "w")
      if file then
        file:write(vim.json.encode(config))
        file:close()
        return true
      end
      return false
    end
    
    -- 添加一个新的自定义任务模板用于运行cmake.launchtarget
    local overseer = require("overseer")
    overseer.register_template({
      name = "CMake Run Launch Target",
      builder = function()
        local cmake = require("cmake-tools")
        local launch_target = cmake.get_launch_target()
        
        -- 如果没有设置启动目标，则返回nil
        if not launch_target or launch_target == "" then
          vim.notify("没有设置CMake启动目标", vim.log.levels.WARN)
          return nil
        end
        
        -- 获取配置文件路径
        local config_path = get_config_path()
        
        -- 读取配置文件
        local config, args = read_config(config_path, launch_target)
        
        -- 如果没有找到目标的参数配置，则要求用户输入
        if #args == 0 then
          vim.notify("未找到 " .. launch_target .. " 的参数配置，请输入参数", vim.log.levels.INFO)
          
          -- 从用户那里获取参数
          local input = vim.fn.input({
            prompt = "输入 " .. launch_target .. " 的参数: ",
            default = "",
            completion = "file"
          })
          
          -- 如果用户输入了参数
          if input and input ~= "" then
            -- 将输入的字符串拆分为参数数组
            for arg in string.gmatch(input, "%S+") do
              table.insert(args, arg)
            end
            
            -- 更新并保存配置
            config[launch_target] = args
            if write_config(config_path, config) then
              vim.notify("已将参数保存到配置文件: " .. config_path, vim.log.levels.INFO)
            else
              vim.notify("保存参数到配置文件失败", vim.log.levels.ERROR)
            end
          end
        else
          vim.notify("使用配置文件中的参数: " .. vim.inspect(args), vim.log.levels.INFO)
        end
        
        -- 构建任务
        return {
          name = "运行 CMake 目标: " .. launch_target,
          builder = function()
            local cmd = { cmake.get_launch_target_path() }
            
            -- 将参数添加到命令中
            if type(args) == "table" then
              for _, arg in ipairs(args) do
                table.insert(cmd, arg)
              end
            end
            
            return {
              cmd = cmd,
              cwd = vim.fn.getcwd(),
              components = { 
                { "on_output_quickfix", set_diagnostics = true },
                "on_result_diagnostics",
                "default" 
              },
            }
          end,
        }
      end,
      condition = {
        filetype = { "cpp", "c", "cmake", "txt" },
      },
      desc = "运行当前CMake启动目标并传递配置文件中的参数",
    })
    
    -- 添加一个特定的模板用于设置CMake目标的参数
    overseer.register_template({
      name = "CMake Set Target Args",
      builder = function()
        local cmake = require("cmake-tools")
        local launch_target = cmake.get_launch_target()
        
        -- 如果没有设置启动目标，则返回nil
        if not launch_target or launch_target == "" then
          vim.notify("没有设置CMake启动目标", vim.log.levels.WARN)
          return nil
        end
        
        -- 获取配置文件路径
        local config_path = get_config_path()
        
        -- 读取现有配置
        local config, current_args = read_config(config_path, launch_target)
        
        -- 构建参数设置任务
        return {
          name = "设置 CMake 目标参数: " .. launch_target,
          builder = function()
            -- 将当前参数转换为字符串用于输入框的默认值
            local current_args_str = table.concat(current_args, " ")
            
            -- 从用户那里获取新参数
            local input = vim.fn.input({
              prompt = "输入 " .. launch_target .. " 的参数: ",
              default = current_args_str,
              completion = "file"
            })
            
            if input == "" then
              return nil -- 用户取消
            end
            
            -- 将输入的字符串拆分为参数数组
            local new_args = {}
            for arg in string.gmatch(input, "%S+") do
              table.insert(new_args, arg)
            end
            
            -- 更新配置
            config[launch_target] = new_args
            
            -- 将更新后的配置写回文件
            if write_config(config_path, config) then
              vim.notify("已保存 " .. launch_target .. " 的参数到: " .. config_path, vim.log.levels.INFO)
            else
              vim.notify("无法写入配置文件: " .. config_path, vim.log.levels.ERROR)
            end
            
            -- 返回一个简单任务用于显示结果
            return {
              cmd = {"echo", "已设置 " .. launch_target .. " 的参数: " .. input},
              components = { "default" },
            }
          end,
        }
      end,
      condition = {
        filetype = { "cpp", "c", "cmake", "txt" },
      },
      desc = "为当前CMake启动目标设置参数并保存到配置文件",
    })
    
    -- 设置默认组件
    opts.component_aliases = vim.tbl_extend("force", opts.component_aliases or {}, {
      -- 默认组件列表
      default = {
        { "display_duration" },
        { "on_output_summarize", max_lines = 10 },
        "on_exit_set_status",
        "on_complete_notify",
      },
      -- 带重启功能的组件
      restartable = {
        { "display_duration" },
        { "on_output_summarize", max_lines = 10 },
        "on_exit_set_status",
        "on_complete_notify",
        "restart_on_success",
      },
      -- 用于长时间运行的后台任务
      background = {
        "on_complete_notify",
        "unique",
      },
    })
    
    -- 设置Overseer界面布局
    opts.form = vim.tbl_extend("force", opts.form or {}, {
      win_opts = {
        winblend = 0,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    })
    
    -- 设置Overseer窗口样式
    opts.task_win = vim.tbl_extend("force", opts.task_win or {}, {
      win_opts = {
        winblend = 0,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    })
    
    -- 添加所有相关快捷键
    local function setup_keymaps()
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true }
      
      -- 全局级别的快捷键
      -- Overseer 主要功能
      keymap("n", "<leader>oo", "<cmd>OverseerToggle<CR>", { desc = "切换 Overseer 窗口", unpack(opts) })
      keymap("n", "<leader>ot", "<cmd>OverseerToggle! bottom<CR>", { desc = "切换 Overseer 任务详情", unpack(opts) })
      keymap("n", "<leader>or", function()
        overseer.run_template({name = "CMake Run Launch Target"})
      end, { desc = "运行 CMake 目标", unpack(opts) })
      keymap("n", "<leader>oa", function()
        overseer.run_template({name = "CMake Set Target Args"})
      end, { desc = "设置 CMake 目标参数", unpack(opts) })
      
      -- Overseer 任务管理
      keymap("n", "<leader>ol", "<cmd>OverseerLoadBundle<CR>", { desc = "加载任务配置", unpack(opts) })
      keymap("n", "<leader>os", "<cmd>OverseerSaveBundle<CR>", { desc = "保存任务配置", unpack(opts) })
      keymap("n", "<leader>ob", "<cmd>OverseerBuild<CR>", { desc = "构建新任务", unpack(opts) })
      keymap("n", "<leader>ox", "<cmd>OverseerQuickAction<CR>", { desc = "快速操作当前任务", unpack(opts) })
      keymap("n", "<leader>o.", "<cmd>OverseerTaskAction<CR>", { desc = "任务操作菜单", unpack(opts) })
      
      -- Overseer 任务控制
      keymap("n", "<leader>od", "<cmd>OverseerDeleteAction<CR>", { desc = "删除任务", unpack(opts) })
      keymap("n", "<leader>oc", "<cmd>OverseerClearAction<CR>", { desc = "清除所有任务", unpack(opts) })
      keymap("n", "<leader>op", "<cmd>OverseerRunCmd<CR>", { desc = "运行shell命令", unpack(opts) })
      keymap("n", "<leader>of", "<cmd>OverseerOpen float<CR>", { desc = "浮动窗口打开任务", unpack(opts) })
      
      -- 组合功能的快捷键
      keymap("n", "<leader>oR", function()
        -- 先停止所有任务，然后重新运行 CMake 目标
        vim.cmd("OverseerClearAction")
        vim.defer_fn(function()
          overseer.run_template({name = "CMake Run Launch Target"})
        end, 100)
      end, { desc = "停止所有任务并运行CMake目标", unpack(opts) })
      
      keymap("n", "<leader>oA", function()
        -- 设置参数后立即运行
        overseer.run_template({name = "CMake Set Target Args"}, function()
          overseer.run_template({name = "CMake Run Launch Target"})
        end)
      end, { desc = "设置参数后立即运行", unpack(opts) })
    end
    
    -- 设置编辑器级别的快捷键
    setup_keymaps()
    
    -- 添加特定文件类型的快捷键
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"c", "cpp", "cmake"},
      callback = function()
        local keymap = vim.keymap.set
        local opts = { noremap = true, silent = true, buffer = true }
        
        -- 文件类型特定的快捷键
        keymap("n", "<F6>", function()
          overseer.run_template({name = "CMake Run Launch Target"})
        end, { desc = "使用Overseer运行CMake目标", unpack(opts) })
        
        keymap("n", "<S-F6>", function()
          overseer.run_template({name = "CMake Set Target Args"})
        end, { desc = "设置CMake目标的参数", unpack(opts) })
        
        -- 快速运行最近的任务
        keymap("n", "<C-F6>", "<cmd>OverseerRun<CR>", { desc = "运行最近任务", unpack(opts) })
        
        -- 使用F7停止所有任务
        keymap("n", "<F7>", "<cmd>OverseerTerminate<CR>", { desc = "终止所有任务", unpack(opts) })
      end
    })
    
    return opts
  end,
  -- 添加插件依赖
  dependencies = {
    "mfussenegger/nvim-dap", -- 用于调试支持
    "Civitasv/cmake-tools.nvim", -- 用于CMake功能
  },
  -- 添加快捷键到插件级别
  keys = {
    -- 全局快捷键
    { "<leader>oo", desc = "切换 Overseer 窗口" },
    { "<leader>or", desc = "运行 CMake 目标" },
    { "<leader>oa", desc = "设置 CMake 目标参数" },
    { "<F6>", desc = "使用 Overseer 运行 CMake 目标" },
  },
}