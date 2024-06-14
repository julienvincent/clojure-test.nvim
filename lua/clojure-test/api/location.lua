local ts = require("nvim-treesitter.ts_utils")

local M = {}

local function extract_ns_name(node)
  if not node then
    return
  end

  if node:type() ~= "list_lit" then
    return
  end

  local ns_sym = node:named_child(0)
  if ns_sym and ns_sym:type() ~= "sym_lit" then
    return
  end

  if ts.get_node_text(ns_sym)[1] ~= "ns" then
    return
  end

  local ns = node:named_child(1)
  if not ns then
    return
  end

  return ts.get_node_text(ns)[1]
end

function M.get_current_namespace()
  local node = ts.get_node_at_cursor()
  if not node then
    return
  end

  local tree = node:tree()
  local document = tree:root()

  for i = 0, document:named_child_count() do
    local child = document:named_child(i)
    local ns = extract_ns_name(child)
    if ns then
      return ns
    end
  end

  return nil
end

function M.get_test_at_cursor()
  local node = ts.get_node_at_cursor()
  if not node then
    return
  end

  local ns = M.get_current_namespace()
  if not ns then
    return
  end

  local tree = node:tree()
  local root = tree:root()

  local root_form = node
  while true do
    local parent = root_form:parent()
    if not parent then
      break
    end

    if parent:id() == root:id() then
      break
    end

    root_form = parent
  end

  local form_type = root_form:named_child(0)
  if ts.get_node_text(form_type)[1] ~= "deftest" then
    return
  end

  local test_name = ts.get_node_text(root_form:named_child(1))[1]

  if not test_name then
    return
  end

  return ns .. "/" .. test_name
end

return M
