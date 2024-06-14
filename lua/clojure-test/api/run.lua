local parser = require("clojure-test.api.report")
local eval = require("clojure-test.api.eval")
local config = require("clojure-test.config")
local ui = require("clojure-test.ui")
local nio = require("nio")

-- This function is called when <Cr> is pressed while on a node in the report
-- tree.
--
-- This function implements a kind of 'go-to-definition' for the various types
-- of nodes
local function handle_on_enter(layout, node)
  nio.run(function()
    local symbol
    local line
    local col

    if node.test then
      symbol = node.test
    end

    local exception
    if node.assertion then
      if node.assertion.exception then
        exception = node.assertion.exception[#node.assertion.exception]
      else
        symbol = node.test
      end
    end

    if node.exception then
      exception = node.exception
    end

    if exception and exception["stack-trace"] ~= vim.NIL then
      symbol = exception["stack-trace"][1].names[1]
      line = exception["stack-trace"][1].line
    end

    if not symbol then
      return
    end

    local meta = eval.eval(eval.API.resolve_metadata_for_symbol, "'" .. symbol)
    if not meta then
      return
    end

    layout:unmount()
    vim.cmd("edit " .. meta.file)
    vim.schedule(function()
      vim.api.nvim_win_set_cursor(0, { line or meta.line or 0, col or meta.column or 0 })
    end)
  end)
end

local M = {}

function M.run_tests(tests)
  local hook = (config.config.hooks or {}).before_run
  if hook then
    hook(tests)
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
