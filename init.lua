require("config.lazy")

vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false

vim.keymap.set("n", "<space><space>s", "<cmd>source %<CR><cmd>echo 'File Sourced'<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":lua<CR>")

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- Bottom Terminal
local job_id = 0
vim.keymap.set("n", "<space>st", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 7)
  job_id = vim.bo.channel
end)

vim.keymap.set("n", "<space>example", function()
  vim.fn.chansend(job_id, { "ls -al\r\n" })
end)

vim.keymap.set("n", "-", "<cmd>Oil<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "<leader>jq", ":%!jq '.'<CR>")
vim.g.grr_ignore_patterns = { '*.log', 'node_modules/', '*.test.js', 'build/',
  "cdk.out/" }

-- Show Keymaps
vim.keymap.set("n", "<leader>km", function()
  vim.cmd("redir @a")
  vim.cmd("silent map")
  vim.cmd("redir END")
  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.cmd("put a")
  vim.cmd("normal! gg")
end, { desc = "Show all keymaps in a scratch buffer" })


-- Ergonomics
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set('n', '<leader>w', ':w<CR>') -- save
vim.keymap.set('n', '<leader>q', ':q<CR>') -- quit
vim.keymap.set('n', ';', ':', { noremap = true })
vim.keymap.set("n", "<C-y>", "ggVGy", { noremap = true })
vim.keymap.set("n", "H", "^", { noremap = true })
vim.keymap.set("n", "L", "$")



-- Enable persistent undo
vim.opt.undofile = true

-- Set a directory to store undo files (adjust as needed)
local undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undodir = undodir

-- Create the directory if it doesn't exist
vim.fn.mkdir(undodir, "p")

vim.diagnostic.config(
  {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true
  }
)

local notify_orig = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg:find("client%.notify") then
    return
  end
  notify_orig(msg, level, opts)
end
