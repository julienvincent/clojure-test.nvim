local M = {}

function M.parse_test_report(test, report)
  local status = "pending"
  local assertions = {}

  if report then
    status = "passed"
    for _, entry in ipairs(report) do
      if entry.type == "error" or entry.type == "fail" then
        status = "failed"
        table.insert(assertions, entry)
      end
      if entry.type == "pass" then
        table.insert(assertions, entry)
      end
    end
  end

  return {
    test = test,
    status = status,
    assertions = assertions,
  }
end

return M
