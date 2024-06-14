local backends = require("clojure-test.backends")

local M = {}

M.default_keys = {
  run_all_tests = "<localleader>ta",
  run_tests = "<localleader>tr",
  run_tests_in_ns = "<localleader>tn",
  rerun_previous = "<localleader>tp",
  load_test_namespaces = "<localleader>tl",
}

M.defaults = {
  use_default_keys = true,

  keys = {},

  hooks = {},

  backend = backends.conjure,
}

return M
