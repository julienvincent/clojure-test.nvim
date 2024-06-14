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

return M
