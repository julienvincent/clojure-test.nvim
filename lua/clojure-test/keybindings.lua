local utils = require("clojure-test.utils")
local api = require("clojure-test.api")

local M = {}

local function setup_keybinding(key, action, description)
  if not key then
    return
  end

  for _, chord in ipairs(utils.into_table(key)) do
    vim.keymap.set("n", chord, action, {
      desc = description,
      silent = true,
    })
  end
end

function M.setup_keybindings(keys)
  local global = keys.global

  setup_keybinding(global.run_all_tests, api.run_all_tests, "Run all tests")
  setup_keybinding(global.run_tests, api.run_tests, "Run tests")
  setup_keybinding(global.run_tests_in_ns, api.run_tests_in_ns, "Run all tests in a namespace")
  setup_keybinding(global.rerun_previous, api.rerun_previous, "Rerun the last run set of tests")
  setup_keybinding(global.load_test_namespaces, api.load_tests, "Find and load test namespaces in classpath")
end

return M
