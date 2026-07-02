-- ~/.config/nvim/lua/plugins/mini.lua
return {
  {
    "echasnovski/mini.files",
    keys = {
      { "<leader>e", function() require("mini.files").open() end },
    },
    config = function()
      require("mini.files").setup()
    end,
  },
}