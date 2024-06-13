local parser = require("clojure-test.api.report")
local eval = require("clojure-test.api.eval")
local ui = require("clojure-test.ui")
local nio = require("nio")

local M = {}

function M.run_tests(tests)
  local layout = ui.layout.create_test_layout()

  layout:mount()

  local tree = ui.report_tree.create_tree(layout)

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
