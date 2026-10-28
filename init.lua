local g = vim.g

g.mapleader = " "
g.maplocalleader = " "
g.have_nerd_font = true

require("plugins") -- ensure plugins can be used by modules
require("config")
