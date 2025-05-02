-- filepath: /home/cx/.config/nvim/lua/plugins/lualine.lua
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    -- Function to fetch cmake-tools status
    local function cmake_status()
      local ok, cmake = pcall(require, 'cmake-tools')
      if not ok then
        return 'CMake: Not Loaded'
      end
      local build_type = cmake.get_build_type() or 'N/A'
      local build_target = cmake.get_build_target() or 'N/A'
      local launch_target = cmake.get_launch_target() or 'N/A'
      return string.format('Build: %s | Target: %s | Launch: %s', build_type, build_target, launch_target)
    end

    -- Lualine configuration
    return {
      options = {
        theme = 'auto',
        section_separators = '',
        component_separators = '',
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {
          {
            function()
              return require('auto-session.lib').current_session_name(true)
            end,
            'filename',
            path = 1,         -- Show relative path
            file_status = true, -- Show file status
            newfile_status = true, -- Show new file status
            symbols = {
              modified = '[+]',
              readonly = '[RO]',
              unnamed = '[No Name]',
              newfile = '[New]',
            }
          },
          {
            'navic',  -- Show current function/scope with navic plugin
            color_correction = nil,
            navic_opts = nil
          },
          cmake_status
        },
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
    }
  end,
  dependencies = {
    "SmiteshP/nvim-navic",  -- Add dependency for function display
  },
  config = function(_, opts)
    require('lualine').setup(opts)
    
    -- Setup navic for showing function context
    local navic = require("nvim-navic")
    navic.setup({
      lsp = {
        auto_attach = true,
        preference = nil,
      },
      highlight = false,
      separator = " > ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true
    })
  end,
}

