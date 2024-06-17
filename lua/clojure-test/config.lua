local backends = require("clojure-test.backends")
local clients = require("clojure-test.clients")

local M = {
  layout = {
    style = "float",
  },

  keys = {
    ui = {
      expand_node = { "l", "<Right>" },
      collapse_node = { "h", "<Left>" },
      go_to = { "<Cr>", "gd" },

      cycle_focus_forwards = "<Tab>",
      cycle_focus_backwards = "<S-Tab>",

      quit = { "q", "<Esc>" },
    },
  },

  hooks = {},

  backend = backends.repl.create(clients.conjure),
}

function M.update_config(new_config)
  local config = vim.tbl_deep_extend("force", M, new_config)
  for key, value in pairs(config) do
    M[key] = value
  end
end

return M
