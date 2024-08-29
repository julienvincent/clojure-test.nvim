local ui_exceptions = require("clojure-test.ui.exceptions")
local config = require("clojure-test.config")

local M = {}

function M.render_exception(sym)
  local exceptions = config.backend:analyze_exception(sym)
  if not exceptions or exceptions == vim.NIL then
    return
  end

  local popup = ui_exceptions.open_exception_popup()
  ui_exceptions.render_exceptions_to_buf(popup.bufnr, exceptions)
end

return M
