local M = {}

function M.create()
  local backend = {}

  function backend:load_test_namespaces() end

  function backend:get_tests()
    return {
      "ns1/test1",
      "ns1/test2",

      "ns2/test1",
      "ns2/test2",
    }
  end

  function backend:run_test(test)
    if test == "ns1/test1" then
      return {
        test = test,
        status = "failed",
        assertions = {
          {
            type = "fail",
            expected = "(= 1 1)",
            actual = "(= 1 0)",
          },
        },
      }
    end

    if test == "ns1/test2" then
      return {
        test = test,
        status = "failed",
        assertions = {
          {
            type = "error",
            exceptions = {
              {
                ["class-name"] = "ExceptionClassName",
                message = "This is the exception message",
                ["stack-trace"] = {
                  {
                    name = "namespace/symbol",
                    line = 12,
                  },
                },
              },
            },
          },
        },
      }
    end

    return {
      test = test,
      status = "passed",
      assertions = {
        {
          type = "pass",
          expected = "(= 1 1)",
          actual = "(= 1 1)",
        },
      },
    }
  end

  function backend:resolve_metadata_for_symbol(symbol)
    return nil
  end

  return backend
end

return M
