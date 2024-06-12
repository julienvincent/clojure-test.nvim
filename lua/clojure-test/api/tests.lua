local eval = require("clojure-test.api.eval")
local nio = require("nio")

local select = nio.wrap(function(choices, opts, cb)
  vim.ui.select(choices, opts, cb)
end, 3)

local function json_decode(data)
  local unwrapped = string.sub(data, 2, -2)
  local unescaped = string.gsub(unwrapped, '\\"', '"')
  return vim.json.decode(unescaped)
end

local M = {}

function M.load_tests()
  pcall(eval.eval("user", "((requiring-resolve 'io.julienvincent.clojure-test.api/load-test-namespaces))").wait)
end

function M.select_tests()
  local success, tests =
    pcall(eval.eval("user", "((requiring-resolve 'io.julienvincent.clojure-test.api/get-all-tests-json))").wait)
  if not success then
    return {}
  end

  local test = select(json_decode(tests), { prompt = "Select test" })
  if not test then
    return {}
  end
  return { test }
end

function M.select_namespaces()
  local success, namespaces =
    pcall(eval.eval("user", "((requiring-resolve 'io.julienvincent.clojure-test.api/get-test-namespaces-json))").wait)
  if not success then
    return {}
  end

  local namespace = select(json_decode(namespaces), { prompt = "Select namespace" })
  if not namespace then
    return {}
  end
  return { namespace }
end

function M.get_tests_in_ns(namespace)
  local success, tests = pcall(
    eval.eval(
      "user",
      "((requiring-resolve 'io.julienvincent.clojure-test.api/get-tests-in-ns-json) '" .. namespace .. ")"
    ).wait
  )
  if not success then
    return {}
  end

  return json_decode(tests)
end

return M
