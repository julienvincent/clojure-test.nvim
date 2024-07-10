local M = {}

local API = {
  load_test_namespaces = "io.julienvincent.clojure-test.json/load-test-namespaces",
  get_all_tests = "io.julienvincent.clojure-test.json/get-all-tests",

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
    return eval(client, API.run_test, "'" .. test)
  end

  function backend:resolve_metadata_for_symbol(symbol)
    return eval(API.resolve_metadata_for_symbol, "'" .. symbol)
  end

  return backend
end

return M
