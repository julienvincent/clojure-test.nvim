local NuiLine = require("nui.line")
local NuiText = require("nui.text")

local M = {}

function M.render_exception_to_buf(buf, exception)
  vim.api.nvim_buf_set_option(buf, "filetype", "clojure")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  local lines = {}

  for _, ex in ipairs(exception) do
    local exception_title = NuiLine()
    exception_title:append(ex["class-name"], "Error")
    exception_title:append(": ", "Comment")
    exception_title:append(ex["message"], "TSString")
    table.insert(lines, exception_title)

    local stack_trace = ex["stack-trace"]
    if stack_trace and stack_trace ~= vim.NIL then
      for _, frame in ipairs(stack_trace) do
        if frame.name and frame.name ~= "" then
          local vars = string.gsub(frame.name, frame.package .. ".", "")
          local var_names = vim.split(vars, "/")
          local var = var_names[1]

          local frame_line = NuiLine()
          frame_line:append("  ")
          frame_line:append(frame.package, "TSNamespace")
          frame_line:append(".", "TSNamespace")
          frame_line:append(var, "TsMethodCall")

          if frame.line and frame.line ~= vim.NIL then
            frame_line:append(" @ ", "Comment")
            frame_line:append(tostring(frame.line), "TSNumber")
          end

          table.insert(lines, frame_line)
        end
      end
    end

    if ex.properties and ex.properties ~= vim.NIL then
      table.insert(lines, NuiLine())

      for _, content in ipairs(vim.split(ex.properties, "\n")) do
        table.insert(lines, NuiLine({ NuiText(content) }))
      end
    end
  end

  for i, line in ipairs(lines) do
    line:render(buf, -1, i)
  end
end

return M
