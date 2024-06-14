local keybindings = require("clojure-test.keybindings")
local config = require("clojure-test.config")

local M = {}

function M.setup(opts)
  opts = opts or {}

  config.update_config(opts)
  keybindings.setup_keybindings(config.keys)
end

return M
