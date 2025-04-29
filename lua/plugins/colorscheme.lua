-- 安装 onedark 主题并设置为默认
return {
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000, -- Ensure it loads first
        opts = {
            theme = "onedark_vivid", -- 设置为 One Dark Vivid 主题
        },
        config = function(_, opts)
            require("onedarkpro").setup(opts)
            vim.cmd.colorscheme("onedark_vivid")
        end,
    },
}