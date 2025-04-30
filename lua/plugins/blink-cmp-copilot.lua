return {
    "saghen/blink.cmp",
    dependencies = {
      "zbirenbaum/copilot.lua",  -- 明确添加依赖关系
      {
        "giuxtaposition/blink-cmp-copilot",
      },
    },
    opts = {
      sources = {
        default = {"copilot", "lsp", "path", "snippets", "buffer"},
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  }