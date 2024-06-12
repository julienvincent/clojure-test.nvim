local config = require("clojure-test.config")
local nio = require("nio")

local M = {}

function M.eval(ns, code)
  local backend = config.config.backend

  local result = backend.eval(ns, code)

  -- nio.run(function()
  --   nio.sleep(20000)
  --
  --   if not result.is_set() then
  --     result.set_error("timeout")
  --   end
  -- end)

  return result
end

return M
