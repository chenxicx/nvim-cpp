return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      -- 显示隐藏文件
      filtered_items = {
        visible = true, -- 当设置为 true 时，显示所有隐藏文件
        hide_dotfiles = false, -- 当设置为 false 时，不再隐藏以点开头的文件
        hide_gitignored = false, -- 当设置为 false 时，不再隐藏 .gitignore 中列出的文件
        hide_hidden = false, -- 当设置为 false 时，不隐藏操作系统设置为隐藏的文件
      },
      -- 添加符号链接支持
      follow_curruent_file = {
        enabled = true, -- 启用当前文件跟踪
        leavaue_dirs_open = true, -- 保持目录打开状态
      },
      follow_symlinks = true, -- 设置为 true，以便跟踪符号链接
      use_libuv_file_watcher = true,
      group_empty_dirs = false,
    },
    -- 保留默认的窗口配置
    window = {
      position = "left",
      width = 30,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
    },
    -- 使文件图标颜色更加丰富
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
      },
      symlink_target = {
        enabled = true, -- 显示符号链接的目标路径
      },
    },
  },
}