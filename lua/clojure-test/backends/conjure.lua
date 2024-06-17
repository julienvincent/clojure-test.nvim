local nio = require("nio")

local M = {}

function M.eval(ns, code, opts)
  opts = opts or {}

  local future = nio.control.future()

  vim.schedule(function()
    local client = require("conjure.client")
    local fn = require("conjure.eval")["eval-str"]
    client["with-filetype"]("clojure", fn, {
      origin = "clojure-test",
      context = ns,
      code = code,
      ["passive?"] = true,
      cb = function(result)
        if result.err then
          vim.notify(result.err, vim.log.levels.ERROR)
          future.set_error(result.err)
        end
        if result.value then
          future.set(result.value)
        end
      end,
    })
  end)

  return future
end

return M
