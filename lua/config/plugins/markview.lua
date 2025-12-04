return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    priority = 1000, -- must load before treesitter
    config = function()
      require("markview").setup({
        preview = {
          icon_provider = "mini",
        },
        experimental = {
          check_rtp_message = false, -- hide the warning
          -- check_rtp = true (default): still fixes load order automatically
        },
      })
    end,
  },
}
