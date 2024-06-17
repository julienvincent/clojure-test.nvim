local config = require("clojure-test.config")

local M = {}

function M.setup(opts)
  opts = opts or {}

  config.update_config(opts)
end

return M
