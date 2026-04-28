require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "bash",
    "json",
  },
  highlight = { enable = true },
  indent = { enable = true },
})
