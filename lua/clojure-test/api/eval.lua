local config = require("clojure-test.config")
local nio = require("nio")

local M = {}

M.API = {
  load_test_namespaces = "io.julienvincent.clojure-test.json/load-test-namespaces",
  get_all_tests = "io.julienvincent.clojure-test.json/get-all-tests",
  get_test_namespaces = "io.julienvincent.clojure-test.json/get-test-namespaces",
  get_tests_in_ns = "io.julienvincent.clojure-test.json/get-tests-in-ns",

  run_test = "io.julienvincent.clojure-test.json/run-test",

  resolve_metadata_for_symbol = "io.julienvincent.clojure-test.json/resolve-metadata-for-symbol",
}

local function statement(api, ...)
  local call_statement = "((requiring-resolve '" .. api .. ")"
  for _, arg in ipairs({ ... }) do
    call_statement = call_statement .. " " .. arg
  end
  return call_statement .. ")"
end

local function eval(ns, code)
  local result = config.backend.eval(ns, code)

  -- nio.run(function()
  --   nio.sleep(20000)
  --
  --   if not result.is_set() then
  --     result.set_error("timeout")
  --   end
  -- end)

  return result
end

local function json_decode(data)
  return vim.json.decode(vim.json.decode(data))
end

function M.eval(api, ...)
  local success, result = pcall(eval("user", statement(api, ...)).wait)
  if not success then
    return
  end
  return json_decode(result)
end

return M
