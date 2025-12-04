-- Key Frequency Tracker (All Modes + Auto Save)
-- Safe: records only aggregated key counts, never text.

local json = vim.json or require("vim.json")

local counts = {}
local history_path = vim.fn.stdpath("data") .. "/keyfreq.json"

----------------------------------------------------------
-- Load history file
----------------------------------------------------------
local function load_history()
  local f = io.open(history_path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  if content == "" then return {} end
  return vim.json.decode(content)
end

----------------------------------------------------------
-- Save history file
----------------------------------------------------------
local function save_history(tbl)
  local f = io.open(history_path, "w")
  if not f then return end
  f:write(vim.json.encode(tbl))
  f:close()
end

local history = load_history()

----------------------------------------------------------
-- Normalize all keys using Neovim's translator
----------------------------------------------------------
local function normalize(key)
  local decoded = vim.fn.keytrans(key)
  return decoded
end

----------------------------------------------------------
-- Count every keypress in all modes
----------------------------------------------------------
local ns = vim.api.nvim_create_namespace("keyfreq")

vim.on_key(function(key)
  if not key or key == "" then return end

  local decoded = normalize(key)

  -- Track frequency
  counts[decoded] = (counts[decoded] or 0) + 1
end, ns)

----------------------------------------------------------
-- Merge session counts into persistent history
----------------------------------------------------------
local function merge_and_save()
  for key, count in pairs(counts) do
    history[key] = (history[key] or 0) + count
  end
  save_history(history)
end

----------------------------------------------------------
-- Auto save on exit
----------------------------------------------------------
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    merge_and_save()
  end,
})

----------------------------------------------------------
-- Reset session
----------------------------------------------------------
local function reset_session()
  for k in pairs(counts) do
    counts[k] = nil
  end
  print("Keyfreq session reset.")
end

----------------------------------------------------------
-- Clear persistent history
----------------------------------------------------------
local function clear_history()
  history = {}
  save_history(history)
  print("Keyfreq history cleared.")
end

----------------------------------------------------------
-- Floating window viewer
----------------------------------------------------------
local function show_table(tbl, title)
  local sorted = {}
  for k, v in pairs(tbl) do
    table.insert(sorted, { key = k, count = v })
  end

  table.sort(sorted, function(a, b)
    return a.count > b.count
  end)

  local lines = { title }
  for _, item in ipairs(sorted) do
    table.insert(lines, string.format("%-10s %d", item.key, item.count))
  end

  local width = 50
  local height = math.min(#lines, 30)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    border = "rounded",
    style = "minimal",
  }

  vim.api.nvim_open_win(buf, true, opts)
end

----------------------------------------------------------
-- Commands
----------------------------------------------------------
vim.api.nvim_create_user_command("Keyfreq", function()
  show_table(counts, "Key Frequency (Session)")
end, {})

vim.api.nvim_create_user_command("KeyfreqHistory", function()
  show_table(history, "Key Frequency (All Time)")
end, {})

vim.api.nvim_create_user_command("KeyfreqReset", reset_session, {})
vim.api.nvim_create_user_command("KeyfreqClearHistory", clear_history, {})
