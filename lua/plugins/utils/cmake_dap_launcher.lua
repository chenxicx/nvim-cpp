-- cmake_dap_launcher.lua
-- 实现DAP与CMake-Tools的集成，使调试自动使用CMake构建目标

local M = {}

-- 获取cmake-tools的信息
local function get_cmake_info()
  local ok, cmake = pcall(require, "cmake-tools")
  if not ok then
    vim.notify("未找到cmake-tools插件", vim.log.levels.WARN)
    return nil
  end

  local info = {}
  info.build_dir = cmake.get_build_directory()
  info.build_target = cmake.get_build_target()
  info.launch_target = cmake.get_launch_target()
  info.build_type = cmake.get_build_type()
  info.cwd = vim.fn.getcwd()

  -- 如果没有构建目录，则使用默认位置
  if not info.build_dir or info.build_dir == "" then
    info.build_dir = info.cwd .. "/build"
  end

  -- 优先使用启动目标，如果没有则使用构建目标
  info.target_name = info.launch_target or info.build_target
  
  -- 如果没有任何目标信息，则无法使用CMake调试
  if not info.target_name or info.target_name == "" then
    return nil
  end

  -- 构造完整的可执行文件路径
  -- 根据不同的项目结构，可能需要调整路径的生成逻辑
  info.target_path = info.build_dir .. "/" .. info.target_name
  
  -- 检查可执行文件是否存在
  if vim.fn.filereadable(info.target_path) ~= 1 then
    -- 尝试常见的子目录情况
    local alt_paths = {
      info.build_dir .. "/bin/" .. info.target_name,
      info.build_dir .. "/src/" .. info.target_name,
      info.build_dir .. "/Release/" .. info.target_name,
      info.build_dir .. "/Debug/" .. info.target_name,
      info.build_dir .. "/" .. (info.build_type or "") .. "/" .. info.target_name,
    }
    
    for _, path in ipairs(alt_paths) do
      if vim.fn.filereadable(path) == 1 then
        info.target_path = path
        break
      end
    end
    
    -- 如果仍然找不到可执行文件，尝试按CMake生成模式路径查找
    if vim.fn.filereadable(info.target_path) ~= 1 then
      -- 搜索构建目录下的可执行文件
      local find_cmd = "find " .. vim.fn.shellescape(info.build_dir) .. 
                       " -type f -executable -name " .. vim.fn.shellescape(info.target_name)
      local handle = io.popen(find_cmd)
      if handle then
        local result = handle:read("*a")
        handle:close()
        
        if result and result ~= "" then
          -- 取第一个匹配项
          info.target_path = vim.split(result, "\n")[1]
        end
      end
    end
  end
  
  -- 最终检查可执行文件是否存在
  if vim.fn.filereadable(info.target_path) ~= 1 then
    vim.notify("找不到CMake目标可执行文件: " .. info.target_name, vim.log.levels.WARN)
    return nil
  end
  
  return info
end

-- 创建基于CMake的调试配置
local function create_cmake_config(info)
  return {
    name = "Debug CMake Target: " .. info.target_name,
    type = "cppdbg",
    request = "launch",
    program = info.target_path,
    cwd = info.cwd,
    stopOnEntry = false,
    MIMode = "gdb",
    miDebuggerPath = "/usr/bin/gdb",
    setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false
      },
    },
    -- 将参数传递给目标程序
    args = function()
      local input = vim.fn.input("程序参数: ")
      if input and input ~= "" then
        return vim.split(input, " ")
      else
        return {}
      end
    end,
  }
end

-- 智能启动：优先使用CMake目标，如果不是CMake项目则使用常规启动
function M.smart_launch()
  local dap = require("dap")
  
  -- 尝试获取CMake信息
  local cmake_info = get_cmake_info()
  
  if cmake_info then
    -- 使用CMake目标进行调试
    local config = create_cmake_config(cmake_info)
    
    vim.notify("正在调试 CMake 目标: " .. cmake_info.target_name)
    dap.run(config)
  else
    -- 不是CMake项目或没有目标，回退到标准的启动方式
    dap.continue()
  end
end

-- 直接使用当前的CMake目标进行调试
function M.debug_cmake_target()
  local dap = require("dap")
  
  -- 尝试获取CMake信息
  local cmake_info = get_cmake_info()
  
  if cmake_info then
    -- 使用CMake目标进行调试
    local config = create_cmake_config(cmake_info)
    dap.run(config)
  else
    vim.notify("当前没有可用的CMake目标", vim.log.levels.ERROR)
  end
end

return M