return 
{
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
            copilot_node_command = 'node', -- 指定 node 路径
            filetypes = {
                ["*"] = true, -- 在所有文件类型中启用
            },
        })
    end
}
