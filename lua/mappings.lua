-- [[ Basic Keymaps/mappings ]]
local fmt = string.format
local U = require("mega.utils")
local map = U.map

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map("n", "<leader>w", "<cmd>w<cr>", { desc = "write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "quit" })

for i = 0, 9 do
  if i + 1 >= 10 then break end
  local key_string = tostring(i + 1)
  map("n", "<localleader>" .. key_string, fmt("<cmd>%stabnext<cr>", key_string), fmt("tab: jump to tab %s", key_string))
end
map({ "i", "n", "t" }, "<C-Right>", ":tabn<CR>", { desc = "next tab", remap = true })
map({ "i", "n", "t" }, "<C-Left>", ":tabp<CR>", { desc = "prev tab", remap = true })
map({ "i", "n", "t" }, "<C-Up>", ":+tabmove<CR>", { desc = "move tab right", remap = true })
map({ "i", "n", "t" }, "<C-Down>", ":-tabmove<CR>", { desc = "move tab left", remap = true })

map("n", "gb", fmt("<cmd>ls<CR>:b<space>%s", vim.keycode("<tab>")), "current buffers")

map(
  { "n", "o", "s", "v", "x" },
  "<Tab>",
  "%",
  { desc = "jump to opening/closing delimiter", remap = true, silent = false }
)

-- https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
-- c-a / c-e everywhere - RSI.vim provides these
map("c", "<C-n>", "<Down>")
map("c", "<C-p>", "<Up>")
-- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- will insert all matching files e.g. :bd a.js b.js c.js
map("c", "<c-x><c-a>", "<c-a>")
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-b>", "<Left>")
map("c", "<C-d>", "<Del>")
map("c", "<C-k>", [[<C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2]<CR>]])
-- move cursor one character backwards unless at the end of the command line
map("c", "<C-f>", [[getcmdpos() > strlen(getcmdline())? &cedit: "\<Lt>Right>"]], { expr = true })
-- see :h cmdline-editing
map("c", "<Esc>b", [[<S-Left>]])
map("c", "<Esc>f", [[<S-Right>]])

map("i", "<C-a>", "<Home>")
map("i", "<C-e>", "<End>")

map("n", "<leader>:", "<cmd>!<cr>")
map("n", "<leader>;", "<cmd><Up>")

-- TLDR: Conditionally modify character at end of line
-- Description:
-- This function takes a delimiter character and:
--   * removes that character from the end of the line if the character at the end
--     of the line is that character
--   * removes the character at the end of the line if that character is a
--     delimiter that is not the input character and appends that character to
--     the end of the line
--   * adds that character to the end of the line if the line does not end with
--     a delimiter
-- Delimiters:
-- - ","
-- - ";"
---@param character string
---@return function
local function modify_line_end_delimiter(character)
  local delimiters = { ",", ";" }
  return function()
    local line = vim.api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == character then
      vim.api.nvim_set_current_line(line:sub(1, #line - 1))
    elseif vim.tbl_contains(delimiters, last_char) then
      vim.api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
    else
      vim.api.nvim_set_current_line(line .. character)
    end
  end
end

map("n", "<localleader>,", modify_line_end_delimiter(","))
map("n", "<localleader>;", modify_line_end_delimiter(";"))

map("n", "<esc>", function()
  U.clear_ui()
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", true)
end, { silent = true, desc = "clear ui" })

-- Convenient Line operations
map("n", "H", "^")
map("n", "L", "$")
map("v", "L", "g_")

-- TODO: no longer needed; nightly adds these things?
-- map("n", "Y", '"+y$')
-- map("n", "Y", "yg_") -- copy to last non-blank char of the line

-- Remap VIM 0 to first non-blank character
map("n", "0", "^")

map("n", "q", "<Nop>")
map("n", "Q", "@q")
map("v", "Q", ":norm @q<CR>")

-- selections
map("n", "gv", "`[v`]", "reselect pasted content")
map("n", "<leader>V", "V`]", "reselect pasted content")
map("n", "gp", "`[v`]", "reselect pasted content")
map("n", "gV", "ggVG", "select whole buffer")
map("n", "<leader>v", "ggVG", "select whole buffer")

-- Map <leader>o & <leader>O to newline without insert mode
map("n", "<leader>o", ":<C-u>call append(line(\".\"), repeat([\"\"], v:count1))<CR>")
map("n", "<leader>O", ":<C-u>call append(line(\".\")-1, repeat([\"\"], v:count1))<CR>")

-- Jumplist mutations and dealing with word wrapped lines
-- nnoremap("k", "v:count == 0 ? 'gk' : (v:count > 5 ? \"m'\" . v:count : '') . 'k'", { expr = true })
-- nnoremap("j", "v:count == 0 ? 'gj' : (v:count > 5 ? \"m'\" . v:count : '') . 'j'", { expr = true })

-- Fast previous buffer switching
map("n", "<leader><leader>", "<C-^>")

map("n", "<C-f>", "<C-f>zz<Esc><Cmd>lua mega.blink_cursorline(75)<CR>")
map("n", "<C-b>", "<C-b>zz<Esc><Cmd>lua mega.blink_cursorline(75)<CR>")

map("n", "<C-d>", "<C-d>zz<Esc><Cmd>lua mega.blink_cursorline(75)<CR>")
map("n", "<C-u>", "<C-u>zz<Esc><Cmd>lua mega.blink_cursorline(75)<CR>")

map("v", [[J]], [[5j]], "Jump down")
map("v", [[K]], [[5k]], "Jump up")

-- don't yank the currently pasted text // thanks @theprimeagen
vim.cmd([[xnoremap <expr> p 'pgv"' . v:register . 'y']])

-- yank to empty register for D, c, etc.
map("n", "x", "\"_x")
map("n", "X", "\"_X")
map("n", "D", "\"_D")
map("n", "c", "\"_c")
map("n", "C", "\"_C")
map("n", "cc", "\"_S")

map("x", "x", "\"_x")
map("x", "X", "\"_X")
map("x", "D", "\"_D")
map("x", "c", "\"_c")
map("x", "C", "\"_C")

-- Undo breakpoints
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", "!", "!<C-g>u")
map("i", "?", "?<C-g>u")

map("n", "n", "nzz<esc><cmd>lua mega.blink_cursorline(50)<cr>")
map("x", "n", "nzz<esc><cmd>lua mega.blink_cursorline(50)<cr>")
map("o", "n", "nzz<esc><cmd>lua mega.blink_cursorline(50)<cr>")
map("n", "N", "Nzz<esc><cmd>lua mega.blink_cursorline(50)<cr>")
map("x", "N", "Nzz<esc><cmd>lua mega.blink_cursorline(50)<cr>")
map("o", "N", "Nzz<esc><cmd>lua mega.blink_cursorline(50)<cr>")

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
local function search(direction_key, default)
  local c_type = vim.fn.getcmdtype()
  return (c_type == "/" or c_type == "?") and fmt("<CR>%s<C-r>/", direction_key) or default
end
map("c", "<Tab>", function() return search("/", "<Tab>") end, { expr = true })
map("c", "<S-Tab>", function() return search("?", "<S-Tab>") end, { expr = true })

-- REF: https://github.com/mhinz/vim-galore/blob/master/README.md#saner-command-line-history
map("c", "<C-n>", [[wildmenumode() ? "\<c-n>" : "\<down>"]], { expr = true })
map("c", "<C-p>", [[wildmenumode() ? "\<c-p>" : "\<up>"]], { expr = true })

map("n", "<leader>yf", [[:let @*=expand("%:p")<CR>]], "yank file path into the clipboard")
map("n", "yf", [[:let @*=expand("%:p")<CR>]], "yank file path into the clipboard")
