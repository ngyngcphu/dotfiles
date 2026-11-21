return {
  "r-pletnev/pdfreader.nvim",
  lazy = false, -- must be loaded to register the PDF BufReadCmd handler
  dependencies = {
    "folke/snacks.nvim", -- image rendering (kitty graphics protocol)
    "nvim-telescope/telescope.nvim", -- bookmarks / recent books pickers
  },
  config = function()
    require("pdfreader").setup()
  end,
}
