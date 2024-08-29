local M = {}

local API = {
  load_test_namespaces = "io.julienvincent.clojure-test.json/load-test-namespaces",
  get_all_tests = "io.julienvincent.clojure-test.json/get-all-tests",

  run_test = "io.julienvincent.clojure-test.json/run-test",

  resolve_metadata_for_symbol = "io.julienvincent.clojure-test.json/resolve-metadata-for-symbol",
  analyze_exception = "io.julienvincent.clojure-test.json/analyze-exception",
}

local function statement(api, ...)
  local call_statement = "((requiring-resolve '" .. api .. ")"
  for _, arg in ipairs({ ... }) do
    call_statement = call_statement .. " " .. arg
  end
  return call_statement .. ")"
end

local function json_decode(data)
  return vim.json.decode(vim.json.decode(data))
end

local function eval(client, api, ...)
  local success, result = pcall(client.eval("user", statement(api, ...)).wait)
  if not success then
    return
  end
  return json_decode(result)
end

local function parse_test_report(test, report)
  local status = "passed"
  local assertions = {}

  for _, entry in ipairs(report) do
    if entry.type == "error" or entry.type == "fail" then
      status = "failed"
      table.insert(assertions, entry)
    end
    if entry.type == "pass" then
      table.insert(assertions, entry)
    end
  end

  return {
    test = test,
    status = status,
    assertions = assertions,
  }
end

function M.create(client)
  local backend = {}

  function backend:load_test_namespaces()
    eval(client, API.load_test_namespaces)
  end

  function backend:get_tests()
    local tests = eval(client, API.get_all_tests)
    return tests or {}
  end

  function backend:run_test(test)
    local report = eval(client, API.run_test, "'" .. test)
    return parse_test_report(test, report)
  end

  function backend:resolve_metadata_for_symbol(symbol)
    return eval(client, API.resolve_metadata_for_symbol, "'" .. symbol)
  end

  function backend:analyze_exception(symbol)
    return eval(client, API.analyze_exception, "'" .. symbol)
  end

  return backend
end

return M
