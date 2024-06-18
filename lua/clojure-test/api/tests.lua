local eval = require("clojure-test.api.eval")
local nio = require("nio")

local select = nio.wrap(function(choices, opts, cb)
  vim.ui.select(choices, opts, cb)
end, 3)

local M = {}

function M.load_tests()
  vim.notify("Loading tests...", vim.log.levels.INFO)
  eval.eval(eval.API.load_test_namespaces)
  vim.notify("Test namespaces loaded!", vim.log.levels.INFO)
end

function M.get_all_tests()
  local tests = eval.eval(eval.API.get_all_tests)
  if not tests then
    return {}
  end
  return tests
end

function M.select_tests()
  local tests = M.get_all_tests()

  local test = select(tests, { prompt = "Select test" })
  if not test then
    return {}
  end
  return { test }
end

function M.select_namespaces()
  local namespaces = eval.eval(eval.API.get_test_namespaces)
  if not namespaces then
    return {}
  end

  local namespace = select(namespaces, { prompt = "Select namespace" })
  if not namespace then
    return {}
  end
  return { namespace }
end

function M.get_tests_in_ns(namespace)
  local tests = eval.eval(eval.API.get_tests_in_ns, "'" .. namespace)
  if not tests then
    return {}
  end
  return tests
end

return M
