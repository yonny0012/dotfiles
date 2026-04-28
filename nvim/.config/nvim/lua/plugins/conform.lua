require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 500,
  },
})
