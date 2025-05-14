return
{
  "coffebar/neovim-project",
  opts = {
    projects = { -- define project roots
      "~/ws/muxin/mp500/mxm_navigation/",
      "~/ws/muxin/mp500_1/mxm_navigation/",
      "~/ws/muxin/mp500_2/mxm_navigation/",
      "~/ws/muxin/mp510/mxm_navigation/",
      "~/ws/muxin/mp600/mxm_navigation/",
      "~/ws/muxin/mp600_1/mxm_navigation/",
    },
    picker = {
      type = "telescope", -- or "fzf-lua"
    }
  },
  init = function()
    -- enable saving the state of plugins in the session
    vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
  end,
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    -- optional picker
    { "nvim-telescope/telescope.nvim", tag = "0.1.4" },
    -- optional picker
    { "ibhagwan/fzf-lua" },
    { "Shatur/neovim-session-manager" },
  },
  lazy = false,
  priority = 100,
}