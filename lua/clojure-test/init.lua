local defaults = require("clojure-test.defaults")
local config = require("clojure-test.config")
local keybindings = require("clojure-test.keybindings")

local M = {}

local function setup_keybingings()
  local keys = config.config.keys

  keybindings.setup_keybindings({
    keys = keys,
  })
end

function M.setup(opts)
  opts = opts or {}

  local keys = opts.keys or {}

  if type(opts.use_default_keys) ~= "boolean" or opts.use_default_keys then
    keys = vim.tbl_deep_extend("force", defaults.default_keys, opts.keys or {})
  end

  config.update_config(defaults.defaults)
  config.update_config(vim.tbl_deep_extend("force", opts, {
    keys = keys,
  }))

  setup_keybingings()
end

return M
