return {
  -- 这是一个自定义插件配置，用于高亮 C/C++ 特殊注释
  {
    -- 不需要外部插件，使用内建功能
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {},
    config = function()
      -- 创建高亮组
      vim.api.nvim_set_hl(0, "CppNoteComment", { fg = "#10B981", bold = false })
      vim.api.nvim_set_hl(0, "CppQuestionComment", { fg = "#2563EB", bold = false })
      vim.api.nvim_set_hl(0, "CppErrorComment", { fg = "#DC2626", bold = false })
      -- 添加默认注释的高亮组（灰色）
      vim.api.nvim_set_hl(0, "CppDefaultComment", { fg = "#888888" })

      -- 创建一个自动命令组
      local augroup = vim.api.nvim_create_augroup("CustomCppHighlights", { clear = true })

      -- 添加自动命令，在打开 C/C++ 文件时应用高亮
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc", "*.hh" },
        group = augroup,
        callback = function()
          -- 清除之前可能存在的匹配
          pcall(function()
            for i = 1, vim.fn.getmatches() do
              vim.fn.matchdelete(i)
            end
          end)

          -- 使用显式优先级确保特殊注释能够覆盖普通注释的高亮
          -- 先添加普通注释的匹配模式（较低优先级）
          vim.fn.matchadd("CppDefaultComment", [[\/\/[^*?!].*$]], 10)
          vim.fn.matchadd("CppDefaultComment", [[^\/\/\s*$]], 10)  -- 匹配单独的 // 注释

          -- 再添加特殊注释的匹配模式（较高优先级）
          -- 修正 //* 注释的匹配模式，确保它不会被错误解释为正则表达式特殊字符
          vim.fn.matchadd("CppNoteComment", [[\(\/\/\*\).*$]], 11)
          vim.fn.matchadd("CppQuestionComment", [[\(\/\/?\).*$]], 11)
          vim.fn.matchadd("CppErrorComment", [[\(\/\/!\).*$]], 11)
        end,
      })

      -- 添加导航命令，让用户可以在这些特殊注释之间跳转
      vim.api.nvim_create_user_command("NextSpecialComment", function()
        vim.fn.search([[\(\/\/\*\|\/\/?\|\/\/!\)]], "w")
      end, {})

      vim.api.nvim_create_user_command("PrevSpecialComment", function()
        vim.fn.search([[\(\/\/\*\|\/\/?\|\/\/!\)]], "bw")
      end, {})

      -- 添加键位映射，方便导航
      vim.keymap.set("n", "]c", ":NextSpecialComment<CR>", { silent = true, desc = "跳转到下一个特殊注释" })
      vim.keymap.set("n", "[c", ":PrevSpecialComment<CR>", { silent = true, desc = "跳转到上一个特殊注释" })

      -- 添加导航命令，让用户可以在所有注释之间跳转（包括普通注释）
      vim.api.nvim_create_user_command("NextComment", function()
        vim.fn.search([[\/\/]], "w")
      end, {})

      vim.api.nvim_create_user_command("PrevComment", function()
        vim.fn.search([[\/\/]], "bw")
      end, {})

      -- 确保搜索模式与高亮模式保持一致
      local special_comment_pattern = [[\(\/\/\*\|\/\/?\|\/\/!\)]]

      -- 添加命令，列出当前文件中的所有特殊注释
      vim.api.nvim_create_user_command("ListSpecialComments", function()
        -- 保存当前位置
        local save_cursor = vim.fn.getpos(".")
        local comments = {}

        -- 跳到文件开头
        vim.fn.cursor(1, 1)

        -- 搜集所有特殊注释
        while true do
          local found = vim.fn.search(special_comment_pattern, "W")
          if found == 0 then
            break
          end

          local line_num = vim.fn.line(".")
          local line_text = vim.fn.getline(".")
          local comment_type = "Unknown"

          -- 确定注释类型
          if line_text:match("^%s*//[*]") then
            comment_type = "NOTE"
          elseif line_text:match("^%s*//[?]") then
            comment_type = "QUESTION"
          elseif line_text:match("^%s*//[!]") then
            comment_type = "ERROR"
          end

          table.insert(comments, { line_num = line_num, text = line_text, type = comment_type })
        end

        -- 恢复光标位置
        vim.fn.setpos(".", save_cursor)

        -- 如果找到注释，显示在 quickfix 窗口中
        if #comments > 0 then
          local qf_list = {}
          for _, comment in ipairs(comments) do
            table.insert(qf_list, {
              filename = vim.fn.expand("%:p"),
              lnum = comment.line_num,
              text = "[".. comment.type .."] " .. comment.text,
            })
          end
          vim.fn.setqflist(qf_list)
          vim.cmd("copen")
        else
          print("No special comments found")
        end
      end, {})

      -- 添加命令，列出当前文件中的所有注释（包括普通注释）
      vim.api.nvim_create_user_command("ListAllComments", function()
        -- 保存当前位置
        local save_cursor = vim.fn.getpos(".")
        local comments = {}

        -- 跳到文件开头
        vim.fn.cursor(1, 1)

        -- 搜集所有注释
        while true do
          local found = vim.fn.search([[\/\/]], "W")
          if found == 0 then
            break
          end

          local line_num = vim.fn.line(".")
          local line_text = vim.fn.getline(".")
          table.insert(comments, { line_num = line_num, text = line_text })
        end

        -- 恢复光标位置
        vim.fn.setpos(".", save_cursor)

        -- 如果找到注释，显示在 quickfix 窗口中
        if #comments > 0 then
          local qf_list = {}
          for _, comment in ipairs(comments) do
            table.insert(qf_list, {
              filename = vim.fn.expand("%:p"),
              lnum = comment.line_num,
              text = comment.text,
            })
          end
          vim.fn.setqflist(qf_list)
          vim.cmd("copen")
        else
          print("No comments found")
        end
      end, {})
    end,

    --  all commands
    --  "NextSpecialComment",
    --  "PrevSpecialComment",
    --  "ListSpecialComments",
    --  "ListAllComments",
  },
}
