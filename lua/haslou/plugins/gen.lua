return {
    "David-Kunz/gen.nvim",
    lazy = true,

    config = function()
        local keymap = vim.keymap -- for conciseness
        keymap.set("v", "<leader>]", ":Gen<CR>")
        keymap.set("n", "<leader>]", ":Gen<CR>")
    end,
}
