return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = function()
            -- 动态生成命令，确保使用当前的工作目录
            return {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              -- 不在这里指定compile_commands.json路径，将通过on_new_config处理
              "--all-scopes-completion",
              "--inlay-hints=false", -- 禁用内联提示，包括参数名称
            }
          end,
          root_dir = function(fname)
            -- 确保使用正确的项目根目录
            local util = require('lspconfig.util')
            return util.root_pattern('compile_commands.json', 'compile_flags.txt', 'CMakeLists.txt', '.git')(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
          end,
        },
      },
      setup = {
        clangd = function(_, opts)
          -- 获取基本能力
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.offsetEncoding = {"utf-8", "utf-16"}
          opts.capabilities = capabilities
          
          -- 重要：在创建每个客户端实例时动态配置compile_commands.json路径
          opts.on_new_config = function(new_config, new_root_dir)
            -- 构建基于当前工作区的路径
            local compile_commands_paths = {
              new_root_dir .. "/compile_commands.json",
              new_root_dir .. "/out/Debug/compile_commands.json",
              new_root_dir .. "/out/Release/compile_commands.json",
              new_root_dir .. "/vs-build/compile_commands.json",
              new_root_dir .. "/vs-build/Release/compile_commands.json",
              new_root_dir .. "/vs-build/Debug/compile_commands.json",
              new_root_dir .. "/build/compile_commands.json",
              new_root_dir .. "/Build/compile_commands.json",
              new_root_dir .. "/cmake-build-debug/compile_commands.json",
              new_root_dir .. "/cmake-build-release/compile_commands.json",
            }
            
            -- 检查哪个路径存在，并使用第一个找到的路径
            for _, path in ipairs(compile_commands_paths) do
              if vim.fn.filereadable(path) == 1 then
                -- 找到了compile_commands.json，添加到命令行参数中
                local command_dir = vim.fn.fnamemodify(path, ":h")
                local cmd = new_config.cmd
                if type(cmd) == "function" then
                  cmd = cmd()
                end
                
                -- 移除旧的compile-commands-dir参数（如果有）
                for i = #cmd, 1, -1 do
                  if string.match(cmd[i] or "", "^%-%-compile%-commands%-dir") then
                    table.remove(cmd, i)
                  end
                end
                
                -- 添加新的路径
                table.insert(cmd, "--compile-commands-dir=" .. command_dir)
                new_config.cmd = cmd
                
                break
              end
            end
            
            -- 设置init_options，确保它们被应用
            new_config.init_options = new_config.init_options or {}
            new_config.init_options.compilationDatabasePath = new_root_dir
            new_config.init_options.fallbackFlags = {
              "-std=c++17",
              "-Wall",
              "-Wextra",
              "-Wpedantic",
            }
            new_config.init_options.clangdFileStatus = true
            new_config.init_options.usePlatformIo = true
            new_config.init_options.offsetEncoding = "utf-8"
          end

          
          -- 手动设置clangd
          local lspconfig = require("lspconfig")
          lspconfig.clangd.setup(opts)
          
          -- 设置clangd_extensions
          local has_clangd_ext, clangd_ext = pcall(require, "clangd_extensions")
          if has_clangd_ext then
            clangd_ext.setup({
              server = opts,
              extensions = {
                autoSetHints = false,
                inlay_hints = {
                  inline = false,
                  -- 完全禁用参数名称提示
                  parameters = false,
                  -- 完全禁用类型提示
                  types = false,
                  -- 禁用其他类型的提示
                  only_current_line = false,
                  only_current_line_autocmd = "CursorHold",
                  show_parameter_hints = false,
                  parameter_hints_prefix = "",
                  other_hints_prefix = "",
                  max_len_align = false,
                  max_len_align_padding = 1,
                  right_align = false,
                  right_align_padding = 7,
                  highlight = "Comment",
                  priority = 100,
                },
                ast = {
                  role_icons = {
                    type = "🄣", declaration = "🄓", expression = "🄔",
                    statement = ";", specifier = "🄢", ["template argument"] = "🆃",
                  },
                  kind_icons = {
                    Compound = "🄲", Recovery = "🅁", TranslationUnit = "🅄",
                    PackExpansion = "🄿", TemplateTypeParm = "🅃",
                    TemplateTemplateParm = "🅃", TemplateParamObject = "🅃",
                  },
                },
                hover = { enabled = true},
              }
            })
          end
          
          return true
        end,
      },
    },
  },

  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function() end,
  },
}
