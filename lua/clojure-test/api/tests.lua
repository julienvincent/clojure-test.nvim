local config = require("clojure-test.config")
local utils = require("clojure-test.utils")
local nio = require("nio")

local select = nio.wrap(function(choices, opts, cb)
  vim.ui.select(choices, opts, cb)
end, 3)

local M = {}

function M.load_tests()
  vim.notify("Loading tests...", vim.log.levels.INFO)
  config.backend:load_test_namespaces()
  vim.notify("Test namespaces loaded!", vim.log.levels.INFO)
end

function M.get_all_tests()
  return config.backend:get_tests()
end

function M.get_test_namespaces()
  local tests = M.get_all_tests()
  local namespaces = {}
  for _, test in ipairs(tests) do
    local parsed = utils.parse_test(test)
    if not utils.included_in_table(namespaces, parsed.ns) then
      table.insert(namespaces, parsed.ns)
    end
  end
  return namespaces
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
  local namespaces = M.get_test_namespaces()
  local namespace = select(namespaces, { prompt = "Select namespace" })
  if not namespace then
    return {}
  end
  return { namespace }
end

function M.get_tests_in_ns(namespace)
  local tests = M.get_all_tests()
  return vim.tbl_filter(function(test)
    local parsed = utils.parse_test(test)
    return parsed.ns == namespace
  end, tests)
end

return M
