local NuiLine = require("nui.line")

local M = {}

function M.render_exception_to_buf(buf, exception)
  vim.api.nvim_buf_set_option(buf, "filetype", "")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  local lines = {}

  for _, ex in ipairs(exception) do
    local line = NuiLine()
    line:append(ex["class-name"], "Error")
    line:append(": ", "Comment")
    line:append(ex["message"])
    table.insert(lines, line)

    local stack_trace = ex["stack-trace"]
    if stack_trace and stack_trace ~= vim.NIL then
      for _, frame in ipairs(stack_trace) do
        if frame.name and frame.name ~= "" then
          local line = NuiLine()
          local vars = string.gsub(frame.name, frame.package .. ".", "")
          local var_names = vim.split(vars, "/")
          local var = var_names[1]
          line:append("  ")
          line:append(frame.package, "TSNamespace")
          line:append(".", "TSNamespace")
          line:append(var, "TsMethodCall")

          if frame.line and frame.line ~= vim.NIL then
            line:append(" @ ", "Comment")
            line:append(tostring(frame.line), "TSNumber")
          end

          table.insert(lines, line)
        end
      end
    end
  end

  for i, line in ipairs(lines) do
    line:render(buf, -1, i)
  end
end

return M
