local backends = require("clojure-test.backends")

local M = {
  keys = {
    global = {
      run_all_tests = "<localleader>ta",
      run_tests = "<localleader>tr",
      run_tests_in_ns = "<localleader>tn",
      rerun_previous = "<localleader>tp",
      load_test_namespaces = "<localleader>tl",
    },

    ui = {
      expand_node = "l",
      collapse_node = "h",
      go_to = "<Cr>",

      cycle_focus_forwards = "<Tab>",
      cycle_focus_backwards = "<S-Tab>",

      quit = { "<Esc>", "q" },
    },
  },

  hooks = {},

  backend = backends.conjure,
}

function M.update_config(new_config)
  local config = vim.tbl_deep_extend("force", M, new_config)
  for key, value in pairs(config) do
    M[key] = value
  end
end

return M
