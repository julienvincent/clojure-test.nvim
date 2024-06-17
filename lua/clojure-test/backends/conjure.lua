local nio = require("nio")

local M = {}

function M.eval(ns, code, opts)
  opts = opts or {}

  local future = nio.control.future()

  vim.schedule(function()
    local errors = {}
    local value

    local client = require("conjure.client")
    local fn = require("conjure.eval")["eval-str"]
    client["with-filetype"]("clojure", fn, {
      origin = "clojure-test",
      context = ns,
      code = code,
      ["passive?"] = true,
      cb = function(result)
        if result.err then
          table.insert(errors, result.err)
        end
        if result.value then
          value = result.value
        end

        if result.status["eval-error"] then
          vim.notify(table.concat(errors, "\n"), vim.log.levels.ERROR)
          future.set_error("")
        end

        if result.status.done and not future.is_set() then
          if not value then
            vim.notify("No result received", vim.log.levels.ERROR)
            future.set_error("")
          else
            future.set(value)
          end
        end
      end,
    })
  end)

  return future
end

return M
