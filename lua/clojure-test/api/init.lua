local location = require("clojure-test.api.location")
local tests_api = require("clojure-test.api.tests")
local run_api = require("clojure-test.api.run")
local nio = require("nio")

local M = {}

M.state = {
  previous = nil,
}

function M.run_all_tests()
  nio.run(function()
    local tests = tests_api.get_all_tests()
    if #tests == 0 then
      return
    end
    M.state.previous = tests
    run_api.run_tests(tests)
  end)
end

function M.run_tests()
  nio.run(function()
    local current_test = location.get_test_at_cursor()

    local tests
    if current_test then
      tests = { current_test }
    else
      tests = tests_api.select_tests()
    end

    if #tests == 0 then
      return
    end

    M.state.previous = tests
    run_api.run_tests(tests)
  end)
end

function M.run_tests_in_ns()
  nio.run(function()
    local namespaces
    local current_namespace = location.get_current_namespace()
    if current_namespace then
      namespaces = { current_namespace }
    else
      namespaces = tests_api.select_namespaces()
    end

    local tests = {}
    for _, namespace in ipairs(namespaces) do
      local ns_tests = tests_api.get_tests_in_ns(namespace)
      for _, test in ipairs(ns_tests) do
        table.insert(tests, test)
      end
    end

    if #tests == 0 then
      return
    end

    M.state.previous = tests
    run_api.run_tests(tests)
  end)
end

function M.rerun_previous()
  nio.run(function()
    if not M.state.previous then
      return
    end
    run_api.run_tests(M.state.previous)
  end)
end

function M.load_tests()
  nio.run(function()
    tests_api.load_tests()
  end)
end

return M
