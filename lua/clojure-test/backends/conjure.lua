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
      ["on-result"] = function(result)
        future.set(result)
      end,
    })
  end)

  return future
end

return M
