require("config.dir")
require("config.keymaps")
require("config.winbar")
require("config.statusline")

local o = vim.o

o.termguicolors = true -- enable 24-bit RGB color in TUI
o.timeoutlen = 250 -- default 1000, decrease wait time for mapped sequences
o.mouse = "a" -- mouse works in all modes
o.confirm = true -- confirmation dialog

o.swapfile = false -- use swapfile for a buffer
o.backup = false -- keep backup file after overwriting a file
o.autoread = true -- auto read file when changed from the outside
o.undofile = true -- save undo information in a file
local undodir = "/tmp/nvim/undo/"
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir("undodir", "p")
end
o.undodir = undodir

o.shiftwidth = 2
o.tabstop = 2 -- # cols between two tab stops
o.softtabstop = 2 -- # cols between two soft tab stops
o.expandtab = true -- use spaces when <tab> is inserted
o.breakindent = true -- wrapped line repeats indent

o.cursorline = true -- highlight screen line of the cursor
o.number = true -- print line number in front of each line
o.relativenumber = true -- relative line numbers
o.signcolumn = "number" -- when and how to display the sign column
o.list = true -- show <tab>, <eol>, ...

o.smartcase = true -- no ignore case

-- vim.opt :append helper
vim.opt.guicursor = "n-v-c-sm:block" -- default cursor
vim.opt.guicursor:append("i-ci-t:block-blinkwait0-blinkon500-blinkoff250-TermCursor")

-- default value
-- o.grpeprg = "rg --vimpgrep -uu"

-- TODO: pum settings?

-- TODO: fold settings?
