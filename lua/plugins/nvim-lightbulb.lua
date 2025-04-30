return {
  'kosayoda/nvim-lightbulb',
  event = { "CursorHold", "CursorHoldI" },
  config = function()
    require("nvim-lightbulb").setup({
      -- 在状态栏显示灯泡图标
      status_text = {
        enabled = true,
        text = "💡",
        text_unavailable = ""
      },
      -- 自动显示代码操作
      autocmd = {
        enabled = true,
        -- 更新频率（毫秒）
        updatetime = 200,
      },
      -- 忽略文件类型
      ignore = {
        -- 可以添加您想忽略的文件类型
        ft = {},
        -- 忽略只读缓冲区
        ro = true,
      },
    })
  end,
}