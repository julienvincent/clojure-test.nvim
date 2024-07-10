local M = {}

local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_range = { cursor[1] - 1, cursor[2] }

  local buf = vim.api.nvim_win_get_buf(0)
  if vim.api.nvim_buf_get_option(buf, "ft") ~= "clojure" then
    return
  end

  local root_lang_tree = vim.treesitter.get_parser(buf, "clojure")
  if not root_lang_tree then
    return
  end

  local root
  for _, tree in pairs(root_lang_tree:trees()) do
    local tree_root = tree:root()
    if tree_root and vim.treesitter.is_in_node_range(tree_root, cursor_range[1], cursor_range[2]) then
      root = tree_root
      break
    end
  end

  if not root then
    return
  end

  return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
end

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

  if vim.treesitter.get_node_text(ns_sym, 0) ~= "ns" then
    return
  end

  local ns = node:named_child(1)
  if not ns then
    return
  end

  return vim.treesitter.get_node_text(ns, 0)
end

function M.get_current_namespace()
  local node = get_node_at_cursor()
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
  local node = get_node_at_cursor()
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
  if vim.treesitter.get_node_text(form_type, 0) ~= "deftest" then
    return
  end

  local test_name = vim.treesitter.get_node_text(root_form:named_child(1), 0)

  if not test_name then
    return
  end

  return ns .. "/" .. test_name
end

return M
