local M = {}

function M.included_in_table(table, item)
  for _, value in pairs(table) do
    if value == item then
      return true
    end
  end
  return false
end

function M.reverse_table(source)
  local reversed = {}
  for i = #source, 1, -1 do
    table.insert(reversed, source[i])
  end
  return reversed
end

-- Ensures a value is a table.
--
-- If given a table it will be returned unmodified.
-- If given a non-table it will be wrapped in a table
function M.into_table(value)
  if type(value) == "table" then
    return value
  end
  return { value }
end

function M.parse_test(test)
    local parts = vim.split(test, "/")
    return {
      ns = parts[1],
      name = parts[2],
    }
end

function M.parse_tests(tests)
  return vim.tbl_map(M.parse_test, tests)
end

return M
