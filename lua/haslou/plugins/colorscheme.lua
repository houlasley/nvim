return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "macchiato",
            background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = false
    })

    -- setup must be called before loading
    vim.cmd.colorscheme "catppuccin"
end,
}

