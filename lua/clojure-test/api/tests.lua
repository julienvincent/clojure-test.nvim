local eval = require("clojure-test.api.eval")
local utils = require("clojure-test.utils")
local nio = require("nio")

local select = nio.wrap(function(choices, opts, cb)
  vim.ui.select(choices, opts, cb)
end, 3)

local M = {}

function M.load_tests()
  eval.eval(eval.API.load_test_namespaces)
end

function M.select_tests(current_test)
  local tests = eval.eval(eval.API.get_all_tests)
  if not tests then
    return {}
  end

  if current_test and utils.included_in_table(tests, current_test) then
    return { current_test }
  end

  local test = select(tests, { prompt = "Select test" })
  if not test then
    return {}
  end
  return { test }
end

function M.select_namespaces(current_namespace)
  local namespaces = eval.eval(eval.API.get_test_namespaces)
  if not namespaces then
    return {}
  end

  if current_namespace and utils.included_in_table(namespaces, current_namespace) then
    return { current_namespace }
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
