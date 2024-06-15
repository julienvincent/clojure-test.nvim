local parser = require("clojure-test.api.report")
local config = require("clojure-test.config")
local eval = require("clojure-test.api.eval")
local ui = require("clojure-test.ui")
local nio = require("nio")

local function go_to_test(layout, test)
  local meta = eval.eval(eval.API.resolve_metadata_for_symbol, "'" .. test)
  if not meta then
    return
  end

  layout:unmount()
  vim.cmd("edit " .. meta.file)
  vim.schedule(function()
    vim.api.nvim_win_set_cursor(0, { meta.line or 0, meta.column or 0 })
  end)
end

local function go_to_exception(layout, exception)
  local stack = exception["stack-trace"]
  if not stack or stack == vim.NIL then
    return
  end

  -- This will iterate over all the frames in a stack trace until a frame points to
  -- a line/file/symbol that is within the project classpath and cwd.
  --
  -- This is a bit hacky as it involves many sequential evals, but it's quick and
  -- dirty and it works.
  --
  -- Future implementation should probably do all this work in clojure land over a
  -- single eval
  for _, frame in ipairs(stack) do
    local symbol = frame.names[1]
    local line = frame.line
    if symbol then
      local meta = eval.eval(eval.API.resolve_metadata_for_symbol, "'" .. symbol)
      if meta and meta ~= vim.NIL then
        layout:unmount()
        vim.cmd("edit " .. meta.file)
        vim.schedule(function()
          vim.api.nvim_win_set_cursor(0, { line or meta.line or 0, meta.column or 0 })
        end)
        return
      end
    end
  end
end

-- This function is called when <Cr> is pressed while on a node in the report
-- tree.
--
-- This function implements a kind of 'go-to-definition' for the various types
-- of nodes
local function handle_on_enter(layout, node)
  nio.run(function()
    if node.test then
      return go_to_test(layout, node.test)
    end

    if node.assertion then
      if node.assertion.exception then
        return go_to_exception(layout, node.assertion.exception[#node.assertion.exception])
      end

      return go_to_test(layout, node.test)
    end

    if node.exception then
      return go_to_exception(layout, node.exception)
    end
  end)
end

local M = {}

function M.run_tests(tests)
  if config.hooks.before_run then
    config.hooks.before_run(tests)
  end

  local layout = ui.layout.create_test_layout()

  layout:mount()

  local tree = ui.report_tree.create_tree(layout, function(node)
    handle_on_enter(layout, node)
  end)

  local reports = {}
  for _, test in ipairs(tests) do
    reports[test] = parser.parse_test_report(test)
  end

  local queue = nio.control.queue()

  tree:set_reports(reports)
  tree:render()

  local semaphore = nio.control.semaphore(1)
  for _, test in ipairs(tests) do
    nio.run(function()
      semaphore.with(function()
        local report = eval.eval(eval.API.run_test, "'" .. test)
        if report then
          queue.put({
            test = test,
            data = report,
          })
        end
      end)
    end)
  end

  while true do
    local report = queue.get()
    if report == nil then
      break
    end

    reports[report.test] = parser.parse_test_report(report.test, report.data)
    tree:set_reports(reports)
    tree:render()
  end
end

return M
