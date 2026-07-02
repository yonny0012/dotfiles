-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = { "lua", "vim", "bash", "c", "cpp", "python", "javascript", "typescript", "json", "html", "css", "markdown" },
      auto_install = true,
    },
  },
}