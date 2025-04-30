return {
  {
    "Civitasv/cmake-tools.nvim",
    lazy = false,
    config = function()
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
      local function read_args_from_json(target_name)
        local config_path = get_config_path()
        local args = {}
        
        if vim.fn.filereadable(config_path) == 1 then
          local file = io.open(config_path, "r")
          if file then
            local content = file:read("*a")
            file:close()
            
            local success, decoded = pcall(vim.json.decode, content)
            if success and decoded then
              if decoded[target_name] then
                args = decoded[target_name]
                vim.notify("从配置文件加载参数: " .. vim.inspect(args), vim.log.levels.INFO)
                return args
              end
            end
          end
        end
        
        -- 如果找不到配置，返回空数组
        return {}
      end
      
      -- 将参数写入配置文件的函数
      local function write_args_to_json(target_name, args)
        local config_path = get_config_path()
        local config = {}
        
        -- 先读取现有配置
        if vim.fn.filereadable(config_path) == 1 then
          local file = io.open(config_path, "r")
          if file then
            local content = file:read("*a")
            file:close()
            
            local success, decoded = pcall(vim.json.decode, content)
            if success and decoded then
              config = decoded
            end
          end
        end
        
        -- 更新配置
        config[target_name] = args
        
        -- 写入文件
        local file = io.open(config_path, "w")
        if file then
          file:write(vim.json.encode(config))
          file:close()
          vim.notify("已保存参数到配置文件: " .. config_path, vim.log.levels.INFO)
          return true
        end
        
        vim.notify("无法写入配置文件: " .. config_path, vim.log.levels.ERROR)
        return false
      end
      
      -- 覆盖 CMakeLaunchArgs 命令
      local cmake_orig = vim.api.nvim_get_commands({})["CMakeLaunchArgs"]
      if cmake_orig then
        vim.api.nvim_create_user_command("CMakeLaunchArgsWithJson", function()
          local cmake = require("cmake-tools")
          local target = cmake.get_launch_target()
          
          if not target or target == "" then
            vim.notify("没有设置 CMake 启动目标", vim.log.levels.WARN)
            return
          end
          
          -- 提供选择：从文件读取或手动输入
          vim.ui.select({"从文件读取参数", "手动输入参数并保存", "使用现有参数(不保存)"}, {
            prompt = "选择参数输入方式:",
          }, function(choice)
            if choice == "从文件读取参数" then
              local args = read_args_from_json(target)
              if #args > 0 then
                -- 设置参数并显示
                cmake.set_launch_args(args)
                vim.notify("已设置 " .. target .. " 的参数: " .. table.concat(args, " "), vim.log.levels.INFO)
              else
                vim.notify("配置文件中未找到 " .. target .. " 的参数", vim.log.levels.WARN)
                -- 回退到手动输入
                vim.defer_fn(function()
                  vim.cmd("CMakeLaunchArgs")
                end, 100)
              end
            elseif choice == "手动输入参数并保存" then
              -- 获取用户输入
              vim.ui.input({
                prompt = "输入 " .. target .. " 的参数: ",
                completion = "file",
              }, function(input)
                if input and input ~= "" then
                  -- 解析参数
                  local args = {}
                  for arg in string.gmatch(input, "%S+") do
                    table.insert(args, arg)
                  end
                  
                  -- 设置参数
                  cmake.set_launch_args(args)
                  
                  -- 保存到配置文件
                  write_args_to_json(target, args)
                end
              end)
            elseif choice == "使用现有参数(不保存)" then
              -- 直接使用原始命令
              vim.cmd("CMakeLaunchArgs")
            end
          end)
        end, {})
      end
      
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
      
      -- 新增：设置启动参数的快捷键 (使用我们的增强版本)
      keymap("n", "<leader>cca", "<cmd>CMakeLaunchArgsWithJson<CR>", { desc = "设置启动参数(带JSON支持)", unpack(opts) })
      
      -- 保留原始命令的访问
      keymap("n", "<leader>ccA", "<cmd>CMakeLaunchArgs<CR>", { desc = "设置启动参数(原始)", unpack(opts) })
    end
  }
}