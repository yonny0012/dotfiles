local rainbow = require("rainbow-delimiters")

vim.g.rainbow_delimiters = {
  strategy = {
    [""] = rainbow.strategy["global"],
  },
  query = {
    [""] = "rainbow-delimiters",
  },
  highlight = {
    "RainbowDelimiterRed",
    "RainbowDelimiterYellow",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
  },
}

local set_hl = vim.api.nvim_set_hl
set_hl(0, "RainbowDelimiterRed", { fg = "#e06c75" })
set_hl(0, "RainbowDelimiterYellow", { fg = "#e5c07b" })
set_hl(0, "RainbowDelimiterBlue", { fg = "#61afef" })
set_hl(0, "RainbowDelimiterOrange", { fg = "#d19a66" })
set_hl(0, "RainbowDelimiterGreen", { fg = "#98c379" })
set_hl(0, "RainbowDelimiterViolet", { fg = "#c678dd" })
set_hl(0, "RainbowDelimiterCyan", { fg = "#56b6c2" })
