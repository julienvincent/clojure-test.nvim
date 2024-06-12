local api = require("clojure-test.api")

local M = {}

function M.setup_keybindings(opts)
  if opts.keys.run_tests then
    vim.keymap.set("n", opts.keys.run_tests, api.run_tests, {
      desc = "Run tests",
      silent = true,
    })
  end

  if opts.keys.run_tests_in_ns then
    vim.keymap.set("n", opts.keys.run_tests_in_ns, api.run_tests_in_ns, {
      desc = "Run all tests in a namespace",
      silent = true,
    })
  end

  if opts.keys.rerun_previous then
    vim.keymap.set("n", opts.keys.rerun_previous, api.rerun_previous, {
      desc = "Rerun the last set of tests",
      silent = true,
    })
  end

  if opts.keys.load_test_namespaces then
    vim.keymap.set("n", opts.keys.load_test_namespaces, api.load_tests, {
      desc = "Load test namespaces in classpath",
      silent = true,
    })
  end
end

return M
